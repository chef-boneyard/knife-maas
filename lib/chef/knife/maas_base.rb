

class Chef
  class Knife
    module MaasBase

      def self.included(includer)
        includer.class_eval do

          deps do
            require 'oauth'
            require 'oauth/signature/plaintext'
            require 'chef/json_compat'
            require 'chef/knife'
            require 'readline'
            Chef::Knife.load_deps
          end
          # add common knife option flags here
        end
      end

      def prepare_access_token(oauth_token, oauth_token_secret, consumer_key, consumer_secret)

        consumer = OAuth::Consumer.new( consumer_key,
                                        consumer_secret,
                                        {
                                          :site => locate_config_value(:maas_site)+"api/1.0/",
                                          :scheme => :header,
                                          :signature_method => "PLAINTEXT"
                                        })

        access_token = OAuth::AccessToken.new( consumer,
                                               oauth_token,
                                               oauth_token_secret
                                             )
        return access_token
      end

      def access_token
        maas_key = "#{locate_config_value(:maas_api_key)}"
        customer_key = maas_key.split(":")[0]
        customer_secret = ""
        token_key = maas_key.split(":")[1]
        token_secret = maas_key.split(":")[2]
        prepare_access_token(token_key, token_secret, customer_key, customer_secret)
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def validate!(keys=[:hostname, :system_id])
        errors = []

        keys.each do |k|
          if locate_config_value(k).nil?
            errors << "You did not provide a valid '#{k}' value."
          end
        end

        if errors.each{|e| ui.error(e)}.any?
          exit 1
        end
      end
    end
  end
end
