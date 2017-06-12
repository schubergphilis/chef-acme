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
            supports status: true, restart: true, reload: true
            action :reload
          end

          ruby_block 'wait for nginx reload' do
            retries 30
            retry_delay 1

            block do
              Timeout.timeout(1) do
                tcp_client = TCPSocket.new("localhost", 443)
                ssl_context = OpenSSL::SSL::SSLContext.new()
                ssl_context.ssl_version = :TLSv1
                ssl_client = OpenSSL::SSL::SSLSocket.new(tcp_client, ssl_context)
                ssl_client.hostname = hostname
                ssl_client.connect
                cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)
                ssl_client.sysclose
                tcp_client.close

                Chef::Log.debug("Got certificate from nginx: #{cert.to_pem}" )

                extensions = cert.extensions || []
                alt_extension = extensions.find { |x| x.oid == 'subjectAltName' }

                alt_names = []

                if !!alt_extension
                  data = OpenSSL::ASN1.decode(alt_extension).value[1].value
                  alt_names = OpenSSL::ASN1.decode(data).map { |x| x.value }
                end

                cn = cert.subject.to_a.map { |x| x[1] if x[0] == 'CN' }

                names = [cn, alt_names].flatten.uniq

                raise "Bad certificate. Got names: #{names.inspect}, expected #{hostname}!" unless names.include?(hostname)
              end
            end
          end
        end

        def teardown_challanges(validation)
          nginx_site "acme-#{new_resource.cn}" do
            action :disable
          end

          service 'nginx' do
            supports status: true, restart: true, reload: true
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
