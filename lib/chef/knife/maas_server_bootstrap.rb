require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerBootstrap < Knife

      include Chef::Knife::MaasBase

      deps do
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife maas server bootstrap (options)"

      option :hostname,
      :short => "-h HOSTNAME",
      :long => "--hostname HOSTNAME",
      :description => "The HOSTNAME inside of MAAS"

      option :template_file,
      :long => "--template-file TEMPLATE",
      :description => "Full path to location of template to use",
      :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
      :default => false

      option :run_list,
      :short => "-r RUN_LIST",
      :long => "--run-list RUN_LIST",
      :description => "Comma separated list of roles/recipes to apply",
      :proc => lambda { |o| o.split(/[\s,]+/) },
      :default => []

      option :zone,
      :short => "-Z ZONE",
      :long => "--zone ZONE",
      :description => "Bootstrap inside a ZONE inside of MAAS"

      def run

        hostname = locate_config_value(:hostname)
        zone = locate_config_value(:zone)

        if (!hostname.nil? && !zone.nil?)
          puts "\nPlease only use one of these options, zone or hostname"
          exit 1
        elsif !hostname.nil?
          response = access_token.request(:post, "/nodes/", {'op'=> 'acquire','name' => "#{hostname}"})
        elsif !zone.nil?
          response = access_token.request(:post, "/nodes/", {'op'=> 'acquire','zone' => "#{zone}"})
        else
          response = access_token.request(:post, "/nodes/?op=acquire")
        end

        hostname = JSON.parse(response.body)["hostname"]
        system_id = JSON.parse(response.body)["system_id"]
        system_info = access_token.request(:get, "/nodes/#{system_id}/")
        puts "Acquiring #{hostname} under your account now...."

        # hack to ensure the node have had time to spin up
        print(".")
        sleep 30
        print(".")

        response = access_token.request(:post, "/nodes/#{system_id}/?op=start")
        puts "\nStarting up #{hostname} now...."

        # hack to ensure the nodes have had time to spin up
        print(".")
        sleep 30
        print(".")

        server = JSON.parse(system_info.body)["hostname"]
        netboot = JSON.parse(system_info.body)["netboot"]
        power_state = JSON.parse(system_info.body)["power_state"]

        until ((netboot == false) && (power_state == "on") ) do
          print(".")
          sleep @initial_sleep_delay ||= 10
          system_info = access_token.request(:get, "/nodes/#{system_id}/")
          netboot = JSON.parse(system_info.body)["netboot"]
          power_state = JSON.parse(system_info.body)["power_state"]
        end

        bootstrap_ip_address = JSON.parse(system_info.body)["ip_addresses"][0]

        print(".")
        sleep 30
        print(".")
        sleep 30

        print(".") until tcp_test_ssh(bootstrap_ip_address) {
          sleep @initial_sleep_delay ||= 10
          puts("connected and done")
        }

        os_system = JSON.parse(system_info.body)["osystem"]

        case os_system
        when "centos"
          user = "cloud-user"
        else
          user = "ubuntu"
        end

        bootstrap_for_node(server, bootstrap_ip_address, user).run

      end

      def bootstrap_for_node(server, bootstrap_ip_address, user)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = bootstrap_ip_address
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] =  user
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:host_key_verify] = config[:host_key_verify]
        bootstrap.config[:chef_node_name] = server
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
        bootstrap.config[:distro] = locate_config_value(:distro)
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = config[:environment]
        bootstrap
      end

      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
      rescue Errno::ENETUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

    end
  end
end
