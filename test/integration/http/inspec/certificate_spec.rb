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
  its('subject.CN') { should match 'test.example.com' }
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

describe command('openssl x509 -in /etc/ssl/test.example.com.crt -noout -text') do
  its('stdout') { should match(/DNS:test.example.com/) }
  its('stdout') { should match(/DNS:test1.example.com/) }
  its('stdout') { should match(/DNS:test2.example.com/) }
end

describe x509_certificate('/etc/ssl/new.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 2048 }
  its('validity_in_days') { should be > 30 }
  its('subject.CN') { should match 'new.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end

# describe x509_private_key('/etc/ssl/new.example.com.key') do
#   it { should be_valid }
#   it { should_not be_encrypted }
#   it { should have_matching_certificate('/etc/ssl/new.example.com.crt') }
# end

describe x509_certificate('/etc/ssl/4096.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 4096 }
  its('validity_in_days') { should be > 30 }
  its('subject.CN') { should match '4096.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end

describe command('openssl x509 -in /etc/ssl/web.example.com.crt -noout -text') do
  its('stdout') { should match(/DNS:web.example.com/) }
  its('stdout') { should match(/DNS:mail.example.com/) }
end

describe command('openssl x509 -in /etc/ssl/ip.example.com.crt -noout -text') do
  its('stdout') { should match(/DNS:ip.example.com/) }
  its('stdout') { should match(/IP(?: Address)?:192.168.18.17/) }
end

describe x509_certificate('/etc/ssl/ec.example.com.crt') do
  it { should be_certificate }
  its('validity_in_days') { should be > 30 }
  its('subject.CN') { should match 'ec.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end

describe x509_certificate('/etc/ssl/ip.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 2048 }
  # Short-lived certificates are valid for ~6 days
  its('validity_in_days') { should be <= 7 }
  its('validity_in_days') { should be > 0 }
  its('subject.CN') { should match 'ip.example.com' }
  its('issuer.CN') { should match /Pebble Intermediate CA/ }
end
