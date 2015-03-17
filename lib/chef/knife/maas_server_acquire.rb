require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerAcquire < Knife

      include Chef::Knife::MaasBase

      deps do
      end

      banner "knife maas server acquire (options)"

      def run
        response = access_token.request(:post, "/nodes/?op=acquire")
        hostname = JSON.parse(response.body)["hostname"]
        puts "Acquiring #{hostname} under your account now...."
      end

    end
  end
end
