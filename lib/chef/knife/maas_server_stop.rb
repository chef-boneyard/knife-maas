require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerStop < Knife
      include Chef::Knife::MaasBase

      banner 'knife maas server stop (options)'

      option :system_id,
             short: '-s SYSTEM_ID',
             long: '--system-id SYSTEM_ID',
             description: 'The System ID inside of MaaS'

      def run
        system_id = locate_config_value(:system_id)
        response = access_token.request(:post, "/nodes/#{system_id}/?op=stop")
        puts "Stopping #{system_id} now...."
      end
    end
  end
end
