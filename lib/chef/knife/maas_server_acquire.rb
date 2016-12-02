require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerAcquire < Knife
      include Chef::Knife::MaasBase

      banner 'knife maas server acquire (options)'

      option :hostname,
             short: '-h HOSTNAME',
             long: '--hostname HOSTNAME',
             description: 'The HOSTNAME inside of MAAS'

      option :zone,
             short: '-Z ZONE',
             long: '--zone ZONE',
             description: 'Bootstrap inside a ZONE inside of MAAS'

      def run
        hostname = locate_config_value(:hostname)
        zone = locate_config_value(:zone)
        print_node_status(acquire_node(hostname: hostname, zone: zone))
      end
    end
  end
end
