class Chef
  class Knife
    # Base Maas module with common methods
    module MaasBase
      def self.included(includer)
        includer.class_eval do
          deps do
            require 'chef/maas/maas'
            require 'chef/api_client'
            require 'chef/node'
            Chef::Knife.load_deps
          end
        end
      end

      def client
        @client ||= begin
          api_key = locate_config_value(:maas_api_key)
          site_uri = locate_config_value(:maas_site)
          ::Maas::Client.new(api_key, site_uri)
        end
      end

      def destroy_item(klass, name, type_name)
        object = klass.load(name)
        object.destroy
        ui.warn("Deleted #{type_name} #{name}")
      rescue Net::HTTPServerException
        ui.warn("Could not find a #{type_name} named #{name} to delete!")
      end

      def acquire_node(hostname: nil, zone: nil)
        unless hostname || zone
          ui.error 'Please specify either a zone or hostname'
          exit 1
        end

        if !hostname.nil?
          client.acquire_node(hostname: hostname)
        elsif !zone.nil?
          client.acquire_node(zone: zone)
        end
      end

      def print_node_status(response_json)
        if response_json.is_a?(Hash) && code = response_json['status']
          ui.info(ui.color(::Maas::NODE_STATUS_MAP[code.to_s][:status],
                           ::Maas::NODE_STATUS_MAP[code.to_s][:color]))
        end
        response_json
      end

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

      def with_timeout(max_time = nil, &block)
        if max_time
          Timeout.timeout(max_time) do
            block.call
          end
        else
          block.call
        end
      rescue Timeout::Error
        ui.error "Request took longer than #{max_time}"
        exit 1
      end

      def wait_with_dots(sleep_seconds = 1)
        print('.') && sleep(sleep_seconds)
      end

      def ensure_system_id!
        system_id = locate_config_value(:system_id) || name_args[0]
        unless system_id
          ui.error('You must provide the system id of the node')
          exit 1
        end
        system_id
      end

      def ensure_chef_node_name!
        hostname = locate_config_value(:hostname)
        node_name = config[:chef_node_name] || hostname
        unless node_name
          ui.error ('You must provide the hostname or chef_node_name')
          exit 1
        end
        node_name
      end
    end
  end
end
