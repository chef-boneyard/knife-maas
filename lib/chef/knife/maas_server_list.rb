require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerList < Knife

      include Chef::Knife::MaasBase

      banner "knife maas server list"

      def run

        server_list = [
          ui.color('System ID', :bold),
          ui.color('Status', :bold),
          ui.color('Power State', :bold),
          ui.color('Hostname', :bold),
          ui.color('Owner', :bold),
          ui.color('IP Address', :bold)
        ]

        response = access_token.request(:get, "/nodes/?op=list")
        JSON.parse(response.body).sort_by { |h| h["system_id"] }.each do |server|
          Chef::Log.debug("Server: #{server.to_yaml}")

          server_list << server['system_id'].to_s
          server_list << begin
                           status = server['substatus'].to_s
                           case status
                           when "2","3","8","11","13","15"
                             ui.color("failed", :red)
                           when "0","1","5","7","9","10","12","14"
                             ui.color("deploying", :yellow)
                           when "4","6"
                             ui.color("deployed", :green)
                           else
                             ui.color(state, :green)
                           end
                         end
          # NEW = 0
          # COMMISSIONING = 1
          # FAILED_COMMISSIONING = 2
          # MISSING = 3
          # READY = 4
          # RESERVED = 5
          # DEPLOYED = 6
          # RETIRED = 7
          # BROKEN = 8
          # DEPLOYING = 9
          # ALLOCATED = 10
          # FAILED_DEPLOYMENT = 11
          # RELEASING = 12
          # FAILED_RELEASING = 13
          # DISK_ERASING = 14
          # FAILED_DISK_ERASING = 15
          server_list <<  begin
                           power_state = server['power_state'].to_s
                           case power_state
                           when "off"
                             ui.color(power_state, :red)
                           when "on"
                             ui.color(power_state, :green)
                           else
                             ui.color(power_state, :yellow)
                           end
                          end
          server_list << server['hostname'].to_s
          server_list << server['owner'].to_s
          server_list << server['ip_addresses'].to_s

        end
        puts ui.list(server_list, :uneven_columns_across, 6)

      end


    end
  end
end
