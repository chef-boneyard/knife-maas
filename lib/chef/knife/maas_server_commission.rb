require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerCommission < Knife
      include Chef::Knife::MaasBase

      banner 'knife maas server commission (options)'

      option :system_id,
             short: '-s SYSTEM_ID',
             long: '--system-id SYSTEM_ID',
             description: 'The System ID inside of MaaS'

      def run
        unless system_id = locate_config_value(:system_id) || name_args[0]
          ui.error('You must provide the system id of the node')
        end
        print_node_status(client.start_node(system_id))
      end
    end
  end
end
