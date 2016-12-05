require 'chef/version_constraint'

class Chef
  class Provider
    class SSLCertificate
      class Nginx < ::Chef::Provider::SSLCertificate

        def initialize(*args)
          super(*args)

          if node.automatic_attrs[:nginx][:version].is_a?(String)
            unless Chef::VersionConstraint.new(">= 1.10").include?(node.automatic_attrs[:nginx][:version])
              Chef::Log.warn("This provider has not been tested with nginx < 1.10")
            end
          end
        end

        attr_reader :nginx

        def ssl_dir
          '/etc/ssl'
        end

        def cert_path
          ::File.join(ssl_dir, "acme-#{new_resource.cn}.crt.pem")
        end

        def key_path
          ::File.join(ssl_dir, "acme-#{new_resource.cn}.key.pem")
        end

        def setup_challanges(validation)
          hostname = validation.hostname
          cert = validation.certificate.to_pem
          pkey = validation.private_key.to_pem

          file cert_path do
            content cert

            mode 00644
            owner node[:nginx][:user]
          end

          file key_path do
            content pkey
            sensitive true

            mode 00600
            owner node[:nginx][:user]
          end

          nginx_site "acme-#{new_resource.cn}" do
            template 'acme-challange.nginx.erb'
            cookbook 'acme'

            variables({
              host: hostname,
              cert: cert_path,
              key: key_path
            })
          end

          service 'nginx' do
            action :reload
          end

          ruby_block 'wait a sec' do
            block do
              sleep 1
            end
          end
        end

        def teardown_challanges(validation)
          nginx_site "acme-#{new_resource.cn}" do
            action :disable
          end

          service 'nginx' do
            action :reload
          end

          file cert_path do
            action :delete
          end

          file key_path do
            action :delete
          end
        end
      end
    end
  end
end
