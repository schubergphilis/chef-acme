#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
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

describe x509_certificate('/etc/ssl/test.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 2048 }
  its('validity_in_days') { should be > 30 }
  its('extensions.subjectAltName') { should include 'DNS:test.example.com' }
  its('extensions.subjectAltName') { should include 'DNS:test1.example.com' }
  its('extensions.subjectAltName') { should include 'DNS:test2.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end

# no corresponding inspec resource
# describe x509_private_key('/etc/ssl/test.example.com.key') do
#   it { should be_valid }
#   it { should_not be_encrypted }
#   it { should have_matching_certificate('/etc/ssl/test.example.com.crt') }
# end

describe command('echo | openssl s_client -connect 0:443 2>&1 | openssl x509 -noout -serial') do
  its('stdout') { should eq command('openssl x509 -in /etc/ssl/test.example.com.crt -noout -serial').stdout }
end

describe x509_certificate('/etc/ssl/new.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 2048 }
  its('validity_in_days') { should be > 30 }
  its('extensions.subjectAltName') { should include 'DNS:new.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end

describe x509_certificate('/etc/ssl/4096.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 4096 }
  its('validity_in_days') { should be > 30 }
  its('extensions.subjectAltName') { should include 'DNS:4096.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end

describe x509_certificate('/etc/ssl/web.example.com.crt') do
  it { should be_certificate }
  its('validity_in_days') { should be > 30 }
  its('extensions.subjectAltName') { should include 'DNS:web.example.com' }
  its('extensions.subjectAltName') { should include 'DNS:mail.example.com' }
end

describe x509_certificate('/etc/ssl/ip.example.com.crt') do
  it { should be_certificate }
  its('validity_in_days') { should be > 20 }
  its('extensions.subjectAltName') { should include 'DNS:ip.example.com' }
  its('extensions.subjectAltName') { should include 'IP Address:192.168.18.17' }
end

describe x509_certificate('/etc/ssl/ec.example.com.crt') do
  it { should be_certificate }
  its('validity_in_days') { should be > 30 }
  its('extensions.subjectAltName') { should include 'DNS:ec.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end

describe x509_certificate('/etc/ssl/short.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 2048 }
  # Short-lived certificates are valid for ~6 days
  its('validity_in_days') { should be <= 7 }
  its('validity_in_days') { should be > 0 }
  its('extensions.subjectAltName') { should include 'DNS:short.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end
