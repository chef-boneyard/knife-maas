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

        if !hostname.nil? && !zone.nil?
          puts "\nPlease only use one of these options, zone or hostname"
          exit 1
        elsif !hostname.nil?
          response = access_token.request(:post, '/nodes/', 'op' => 'acquire', 'name' => "#{hostname}")
        elsif !zone.nil?
          response = access_token.request(:post, '/nodes/', 'op' => 'acquire', 'zone' => "#{zone}")
        else
          response = access_token.request(:post, '/nodes/?op=acquire')
        end

        hostname = Chef::JSONCompat.parse(response.body)['hostname']
        ui.info "Acquiring #{hostname} under your account now...."
      end
    end
  end
end
