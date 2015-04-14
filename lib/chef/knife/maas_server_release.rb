require 'chef/knife/maas_base'
require 'chef/node'
require 'chef/api_client'

class Chef
  class Knife
    class MaasServerRelease < Knife
      include Chef::Knife::MaasBase

      banner 'knife maas server release (options)'

      option :hostname,
             short: '-h HOSTNAME',
             long: '--hostname HOSTNAME',
             description: 'The HOSTNAME inside of MAAS'

      option :system_id,
             short: '-s SYSTEM_ID',
             long: '--system-id SYSTEM_ID',
             description: 'The System ID inside of MAAS'

      option :purge,
             short: '-P',
             long: '--purge',
             boolean: true,
             default: false,
             description: 'Destroy corresponding node and client on the Chef Server, in addition to releasing the MAAS node itself. Assumes node and client have the same name as the server.'

      def destroy_item(klass, name, type_name)
        object = klass.load(name)
        object.destroy
        ui.warn("Deleted #{type_name} #{name}")
      rescue Net::HTTPServerException
        ui.warn("Could not find a #{type_name} named #{name} to delete!")
      end

      def run
        validate!

        system_id = locate_config_value(:system_id)
        hostname = locate_config_value(:hostname)

        if config[:purge]
          thing_to_delete = config[:chef_node_name] || hostname
          destroy_item(Chef::Node, thing_to_delete, 'node')
          destroy_item(Chef::ApiClient, thing_to_delete, 'client')
        else
          ui.warn("Corresponding node and client for the #{hostname} server were not deleted and remain registered with the Chef Server")
        end

        response = access_token.request(:post, "/nodes/#{system_id}/?op=release")
        puts "Releasing #{system_id} back to MAAS now...."
      end
    end
  end
end
