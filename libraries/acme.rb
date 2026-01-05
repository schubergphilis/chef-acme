#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
# Library:: acme
#
# Copyright:: 2015-2021, Schuberg Philis
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

begin
  require 'acme-client'
rescue LoadError => e
  Chef::Log.warn("Acme library dependency 'acme-client' not loaded: #{e}")
end

def names_changed?(cert, names)
  return false if names.empty?

  san_extension = cert.extensions.find { |e| e.oid == 'subjectAltName' }
  return false if san_extension.nil?

  current = san_extension.value.split(', ').map { |v| v.split(':')[1] }
  !(names - current).empty? || !(current - names).empty?
end

def format_names(names)
  return nil if names.nil? || names.empty?

  names.map do |name|
    if valid_ip_address?(name)
      { type: 'ip', value: name }
    else
      { type: 'dns', value: name }
    end
  end
end

def acme_client
  return @client if @client

  # load private_key from disk if present
  private_key_file = node['acme']['private_key_file']
  node.default['acme']['private_key'] = ::File.read(private_key_file) if ::File.exist?(private_key_file)

  private_key = OpenSSL::PKey::RSA.new(node['acme']['private_key'] || 2048)

  directory = new_resource.dir || node['acme']['dir']

  contact = (new_resource.contact.nil? || new_resource.contact.empty?) ? node['acme']['contact'] : new_resource.contact

  @client = Acme::Client.new(private_key: private_key, directory: directory)

  if node['acme']['private_key'].nil?
    acme_client.new_account(contact: contact, terms_of_service_agreed: true)
    node.default['acme']['private_key'] = private_key.to_pem

    # write key to disk for persistence
    directory File.dirname(private_key_file) do
      recursive true
    end

    file private_key_file do
      content private_key.to_pem
      mode '600'
      sensitive true
    end
  end

  @client
end

def acme_order_certs_for(names, profile: nil)
  order_params = { identifiers: names }
  order_params[:profile] = profile if profile
  acme_client.new_order(**order_params)
end

def acme_validate(authz)
  authz.request_validation

  times = 60

  while times > 0
    break unless ( authz.status == 'pending' || authz.status == 'processing' )
    times -= 1
    sleep 1
    authz.reload
  end

  authz
end

def acme_cert(order, cn, key, alt_names = [])
  csr = Acme::Client::CertificateRequest.new(
    common_name: cn,
    names: alt_names,
    private_key: key
  )
  order.finalize(csr: csr)

  while order.status == 'processing'
    sleep 1
    order.reload
  end

  order.certificate
end

def create_subject_alt_names(alt_names)
  return nil if alt_names.nil? || alt_names.empty?

  alt_names.map do |name|
    if valid_ip_address?(name)
      "IP:#{name}"
    else
      "DNS:#{name}"
    end
  end.join(',')
end

def valid_ip_address?(address)
  require 'ipaddr'
  begin
    ip = IPAddr.new(address)
    true
  rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
    false
  end
end

def self_signed_cert(cn, alts, key)
  cert = OpenSSL::X509::Certificate.new
  cert.subject = cert.issuer = OpenSSL::X509::Name.new([['CN', cn, OpenSSL::ASN1::UTF8STRING]])
  cert.not_before = Time.now
  cert.not_after = Time.now + 60 * 60 * 24 * node['acme']['renew']
  if key.is_a?(OpenSSL::PKey::EC)
    cert.public_key = key
  else
    cert.public_key = key.public_key
  end
  cert.serial = 0x0
  cert.version = 2

  ef = OpenSSL::X509::ExtensionFactory.new
  ef.subject_certificate = cert
  ef.issuer_certificate = cert

  cert.extensions = []

  cert.extensions += [ef.create_extension('basicConstraints', 'CA:FALSE', true)]
  cert.extensions += [ef.create_extension('subjectKeyIdentifier', 'hash')]
  san = create_subject_alt_names([cn] + alts)
  cert.extensions += [ef.create_extension('subjectAltName', san)] if san

  cert.sign key, OpenSSL::Digest.new('SHA256')
end
