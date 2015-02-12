require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerAcquire < Knife

      include Chef::Knife::MaasBase

      deps do
      end

      banner "knife maas server acquire (options)"

      option :hostname,
      :short => "-h HOSTNAME",
      :long => "--hostname HOSTNAME",
      :description => "The HOSTNAME inside of MaaS"

      def run
        system_id = locate_config_value(:hostname)
        response = access_token.request(:post, "/nodes/?op=acquire&name=#{hosname}")
        puts "Acquiring #{hostname} under your account now...."
      end


    end
  end
end
