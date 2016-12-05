#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
# Provider:: certificate
#
# Copyright 2015-2016 Schuberg Philis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


class Chef
  class Provider
    class SSLCertificate < Chef::Provider::LWRPBase

      attr_reader :challanges

      use_inline_resources

      def whyrun_supported?
        true
      end

      def load_current_resource
      end

      def check_renewal
        return false if @current_cert.nil?
        @current_cert.not_after >= new_resource.min_expiry
      end

      def check_alt_names
        return false if @current_cert.nil?

        extensions = @current_cert.extensions || []
        alt_extension = extensions.find { |x| x.oid == 'subjectAltName' }

        current_alt_names = []

        if !!alt_extension
          data = OpenSSL::ASN1.decode(alt_extension).value[1].value
          current_alt_names = OpenSSL::ASN1.decode(data).map { |x| x.value }
        end

        current_alt_names.sort == (new_resource.alt_names | [new_resource.cn]).sort
      end

      def check_cn
        return false if @current_cert.nil?

        @current_cert.subject.to_a.map { |x| x[1] if x[0] == 'CN' }.compact.include?(new_resource.cn)
      end

      def check_pkey
        return false if @current_cert.nil?

        @current_cert.check_private_key(@current_key)
      end

      def action_create
        key = acme_ssl_key new_resource.key do
          action :nothing
        end

        key.run_action(:create_if_missing)

        @current_key = key.load

        if ::File.exist?(@new_resource.path)
          @current_cert = ::OpenSSL::X509::Certificate.new ::File.read new_resource.path
        end

        unless (!@current_cert.nil? && check_renewal && check_cn && check_alt_names && check_pkey)
          ::Chef::Log.info("Renewing ACME certificate for #{@new_resource.cn}: renewal = #{check_renewal}, cn = #{check_cn}, alt_name = #{check_alt_names}, pkey = #{check_pkey}")
          ::Chef::Log.warn("WARN Renewing ACME certificate for #{@new_resource.cn}: renewal = #{check_renewal}, cn = #{check_cn}, alt_name = #{check_alt_names}, pkey = #{check_pkey}")

          converge_by("Renew ACME certifiacte") do
            validations = [new_resource.cn, new_resource.alt_names].flatten.compact.map do |domain|
              authz = acme_authz_for(domain)

              case authz.status
              when 'valid'
                ::Chef::Log.info("Authz #{domain} valid")

              when 'pending'
                ::Chef::Log.info("Authz #{domain} pending")
                validation = authz.send(new_resource.validation_method)

                ::Chef::Log.info("Setting up verification...")

                compile_and_converge_action { setup_challanges(validation) }

                ::Chef::Log.info("Requesting verification...")

                validation.request_verification

                ::Chef::Log.info("Waiting for verification...")

                times = 60

                while times > 0
                  break unless validation.verify_status == 'pending'
                  times -= 1
                  sleep 1
                end

                ::Chef::Log.info("Tearing down verification...")

                compile_and_converge_action { teardown_challanges(validation) }

                ::Chef::Log.info("Result: #{validation.status}")

                [domain, validation.status]
              end
            end

            failed_validations = validations.select { |v| v[1] != 'valid' }
            fail "Validation failed for some domains: #{failed_validations}" unless failed_validations.empty?

            begin
              newcert = acme_cert(new_resource.cn, @current_key, new_resource.alt_names)
            rescue Acme::Client::Error => e
              fail "[#{new_resource.cn}] Certificate request failed: #{e.message}"
            else

              cert_data = case new_resource.output
              when :fullchain
                newcert.fullchain_to_pem
              when :crt
                newcert.to_pem
              else
                fail "Unknown output type: #{new_resource.output}"
              end

              key_data = @current_key

              file new_resource.path do
                content cert_data

                owner new_resource.owner
                group new_resource.group
                mode 00644
              end.run_action(:create)
            end
          end
        end
      end
    end
  end
end

