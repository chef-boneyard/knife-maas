require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerRelease < Knife

      include Chef::Knife::MaasBase

      banner "knife maas server release (options)"

      option :system_id,
      :short => "-s SYSTEM_ID",
      :long => "--system-id SYSTEM_ID",
      :description => "The System ID inside of MaaS"

      def run
        system_id = locate_config_value(:system_id)
        response = access_token.request(:post, "/nodes/#{system_id}/?op=release")
        puts "Saying goodbye to #{system_id} now...."
      end


    end
  end
end
