require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerDelete < Knife

      include Chef::Knife::MaasBase

      banner "knife maas server delete (options)"

      option :system_id,
      :short => "-s SYSTEM_ID",
      :long => "--system-id SYSTEM_ID",
      :description => "The System ID inside of MaaS"

      def run
        system_id = locate_config_value(:system_id)
        response = access_token.request(:post, "/nodes/#{system_id}/?op=delete")
        puts "Nuking #{system_id} From Orbit now...."
      end


    end
  end
end
