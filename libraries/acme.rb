#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
# Library:: acme
#
# Copyright 2015-2018 Schuberg Philis
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

def acme_client
  return @client if @client

  private_key = OpenSSL::PKey::RSA.new(node['acme']['private_key'].nil? ? 2048 : node['acme']['private_key'])

  directory = new_resource.dir.nil? ? node['acme']['dir'] : new_resource.dir

  contact = new_resource.contact.nil? ? node['acme']['contact'] : new_resource.contact

  @client = Acme::Client.new(private_key: private_key, directory: directory)

  if node['acme']['private_key'].nil?
    acme_client.new_account(contact: contact, terms_of_service_agreed: true)
    node.normal['acme']['private_key'] = private_key.to_pem
  end

  @client
end

def acme_order_certs_for(names)
  acme_client.new_order(identifiers: names)
end

def acme_validate(authz)
  authz.request_validation

  times = 60

  while times > 0
    break unless authz.status == 'pending'
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

def self_signed_cert(cn, alts, key)
  cert = OpenSSL::X509::Certificate.new
  cert.subject = cert.issuer = OpenSSL::X509::Name.new([['CN', cn, OpenSSL::ASN1::UTF8STRING]])
  cert.not_before = Time.now
  cert.not_after = Time.now + 60 * 60 * 24 * node['acme']['renew']
  cert.public_key = key.public_key
  cert.serial = 0x0
  cert.version = 2

  ef = OpenSSL::X509::ExtensionFactory.new
  ef.subject_certificate = cert
  ef.issuer_certificate = cert

  cert.extensions = []

  cert.extensions += [ef.create_extension('basicConstraints', 'CA:FALSE', true)]
  cert.extensions += [ef.create_extension('subjectKeyIdentifier', 'hash')]
  cert.extensions += [ef.create_extension('subjectAltName', alts.map { |d| "DNS:#{d}" }.join(','))] unless alts.empty?

  cert.sign key, OpenSSL::Digest::SHA256.new
end
