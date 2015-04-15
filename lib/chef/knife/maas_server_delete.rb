require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerDelete < Knife
      include Chef::Knife::MaasBase

      banner 'knife maas server delete (options)'

      option :hostname,
             short: '-h HOSTNAME',
             long: '--hostname HOSTNAME',
             description: 'The HOSTNAME inside of MaaS'

      option :system_id,
             short: '-s SYSTEM_ID',
             long: '--system-id SYSTEM_ID',
             description: 'The System ID inside of MaaS'

      option :purge,
             short: '-P',
             long: '--purge',
             boolean: true,
             default: false,
             description: <<-EOS.gsub(/^ {15}/, '').gsub(/\n/, ' ')
               Destroy corresponding node and client on the Chef Server, in
               addition to destroying the MaaS node itself. Assumes node and
               client have the same name as the server.
             EOS

      def run
        system_id = ensure_system_id!
        node_name = ensure_chef_node_name! if config[:purge]

        if print_node_status(client.delete_node(system_id))
          if config[:purge]
            destroy_item(Chef::Node, node_name, 'node')
            destroy_item(Chef::ApiClient, node_name, 'client')
          else
            ui.warn <<-EOS.gsub(/^ {14}/, '').gsub(/\n/, ' ')
              The corresponding node and client for #{node_name || system_id}
              were not deleted and remain registered with the Chef Server
            EOS
          end
        end
      end
    end
  end
end
