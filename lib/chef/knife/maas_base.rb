class Chef
  class Knife
    # Base Maas module with common methods
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
        consumer = OAuth::Consumer.new(consumer_key,
                                       consumer_secret,
                                       site: "#{locate_config_value(:maas_site)}api/1.0/",
                                       scheme: :header,
                                       signature_method: 'PLAINTEXT'
                                      )

        OAuth::AccessToken.new(consumer,
                               oauth_token,
                               oauth_token_secret
                              )
      end

      def access_token
        consumer_secret = ''
        maas_key = locate_config_value(:maas_api_key)
        consumer_key, token_key, token_secret = maas_key.split(':')
        prepare_access_token(token_key, token_secret, consumer_key, consumer_secret)
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def validate!(keys = %i(hostname system_id))
        errors = []

        keys.each do |k|
          if locate_config_value(k).nil?
            errors << "You did not provide a valid '#{k}' value."
          end
        end

        exit(1) if errors.each { |e| ui.error(e) }.any?
      end
    end
  end
end
