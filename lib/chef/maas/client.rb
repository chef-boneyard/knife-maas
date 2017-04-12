require 'oauth'
require 'oauth/signature/plaintext'
require 'chef/json_compat'
require 'chef/knife'
require 'readline'
require 'timeout'
require 'forwardable'
require 'bson'
require 'xmlsimple'

module Maas
  class Client
    extend Forwardable

    attr_reader :api_key, :site_uri, :access_token, :ui

    def initialize(api_key, site_uri)
      @api_key = api_key
      @site_uri = site_uri
      @access_token = access_token
      @ui = Chef::Knife.ui
    end

    def_delegators :@access_token, :get, :put, :post, :delete, :request

    def acquire_node(hostname: nil, zone: nil)
      if hostname && zone
        ui.error 'Please specify either a zone or hostname'
      elsif !hostname && !zone
        ui.error 'Please specify a zone or hostname'
      end

      if hostname
        response = post('/machines/', 'op' => 'allocate', 'name' => "#{hostname}")
      elsif zone
        response = post('/machines/', 'op' => 'allocate', 'zone' => "#{zone}")
      end

      parse_response(response)
    end

    # TODO: Maybe use method_missing to dynamically build these helpers

    def delete_node(system_id)
      parse_response(delete("/nodes/#{system_id}/"))
    end

    def show_node(system_id)
      bson_parse(get("/nodes/#{system_id}/?op=details"))
    end

    def list_node(system_id)
      list = parse_response(get("/nodes/?id=#{system_id}"))
      if list.is_a? Array
        return list.first
      else
        return Hash.new
      end
    end

    def list_nodes
      parse_response(get('/nodes/'))
    end

    def release_node(system_id)
      parse_response(post("/machines/#{system_id}/?op=release"))
    end

    def start_node(system_id)
      parse_response(post("/machines/#{system_id}/?op=power_on"))
    end

    def deploy_node(system_id)
      parse_response(post("/machines/#{system_id}/?op=deploy"))
    end


    def commission_node(system_id)
      parse_response(post("/machines/#{system_id}/?op=commission"))
    end

    def stop_node(system_id)
      parse_response(post("/machines/#{system_id}/?op=power_off"))
    end

    private

    def access_token
      consumer_key, token_key, token_secret = api_key.split(':')
      consumer = OAuth::Consumer.new(consumer_key,
                                     '',
                                     site: "#{site_uri}api/2.0",
                                     scheme: :header,
                                     signature_method: 'PLAINTEXT'
                                    )
      OAuth::AccessToken.new(consumer,
                             token_key,
                             token_secret
                            )
    end

    def parse_response(response)
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        parse_response_json(response)
      else
        ui.error(parse_response_json(response))
        exit 1
      end
    end

    def parse_response_json(response)
      Chef::JSONCompat.parse(response.body)
    rescue Chef::Exceptions::JSON::ParseError
      response.body
    end

    def bson_parse(response)
      decoded = {}
      Hash.from_bson(StringIO.new(response.body)).each_pair do |type, binary|
        decoded[type] = XmlSimple.xml_in(binary.data)
      end
      decoded
    end

    def with_timeout(max_time = nil, &block)
      if max_time
        Timeout.timeout(max_time) do
          block.call
        end
      else
        block.call
      end
    rescue Timeout::Error
      ui.error "Request took longer than #{max_time}"
      exit 1
    end

    def wait_with_dots(sleep_seconds = 1)
      print('.') && sleep(sleep_seconds)
    end
  end
end
