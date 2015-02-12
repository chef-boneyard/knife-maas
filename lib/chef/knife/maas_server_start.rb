require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerStart < Knife

      include Chef::Knife::MaasBase

      deps do
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife maas server start (options)"

      option :system_id,
      :short => "-s SYSTEM_ID",
      :long => "--system-id SYSTEM_ID",
      :description => "The System ID inside of MaaS"

      def run
        system_id = locate_config_value(:system_id)
        response = access_token.request(:post, "/nodes/#{system_id}/?op=start")
        puts "Starting up #{system_id} now...."
      end


    end
  end
end
