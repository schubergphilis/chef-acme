describe x509_certificate('/etc/ssl/selfsigned.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 2048 }
  its('validity_in_days') { should be > 29 }
  its('extensions.subjectAltName') { should include 'DNS:selfsigned.example.com' }
  its('extensions.subjectAltName') { should include 'DNS:www.selfsigned.example.com' }
  its('issuer.CN') { should match /selfsigned.example.com/ }
end

describe x509_certificate('/etc/ssl/selfsigned-4096.example.com.crt') do
  it { should be_certificate }
  its('key_length') { should be 4096 }
  its('validity_in_days') { should be > 29 }
  its('extensions.subjectAltName') { should include 'DNS:selfsigned-4096.example.com' }
  its('issuer.CN') { should match /selfsigned-4096.example.com/ }
end

describe x509_certificate('/etc/ssl/selfsigned-ec.example.com.crt') do
    it { should be_certificate }
    its('validity_in_days') { should be > 29 }
    its('extensions.subjectAltName') { should include 'DNS:selfsigned-ec.example.com' }
    its('issuer.CN') { should match /selfsigned-ec.example.com/ }
end

describe x509_certificate('/etc/ssl/selfsigned-ec-secp521r1.example.com.crt') do
    it { should be_certificate }
    its('validity_in_days') { should be > 29 }
    its('extensions.subjectAltName') { should include 'DNS:selfsigned-ec-secp521r1.example.com' }
    its('issuer.CN') { should match /selfsigned-ec-secp521r1.example.com/ }
end
