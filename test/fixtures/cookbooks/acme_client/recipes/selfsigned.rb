acme_selfsigned 'selfsigned.example.com' do
  crt     '/etc/ssl/selfsigned.example.com.crt'
  key     '/etc/ssl/selfsigned.example.com.key'
  alt_names ['www.selfsigned.example.com']
end

acme_selfsigned 'selfsigned-4096.example.com' do
  crt       '/etc/ssl/selfsigned-4096.example.com.crt'
  key       '/etc/ssl/selfsigned-4096.example.com.key'
  key_size  4096
end

acme_selfsigned 'selfsigned-ec.example.com' do
  crt       '/etc/ssl/selfsigned-ec.example.com.crt'
  key       '/etc/ssl/selfsigned-ec.example.com.key'
  key_type  'ec'
end

acme_selfsigned 'selfsigned-ec-secp521r1.example.com' do
  crt       '/etc/ssl/selfsigned-ec-secp521r1.example.com.crt'
  key       '/etc/ssl/selfsigned-ec-secp521r1.example.com.key'
  key_type  'ec'
  ec_curve  'secp521r1'
end
