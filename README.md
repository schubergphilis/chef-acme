letsencrypt cookbook
=============
Automatically get/renew free and trusted certificates from Let's Encrypt (letsencrypt.org).

Attributes
----------
### default
* `node['letsencrypt']['contact']` - Contact information, default empty.
* `node['letsencrypt']['endpoint']` - ACME server endpoint, default 'https://acme-staging.api.letsencrypt.org'. Set to `https://acme-v01.api.letsencrypt.org` for real certificates.
* `node['letsencrypt']['renew']` - Days before the certificate expires at which the certificate will be renewed, default 30.

Recipes
-------
### default
Installs the required acme-client rubygem.

Usage
-----
Use the `letsencrypt_certificate` provider to request a certificate. The webserver for the domain for which you are requesting a certificate must be running on the local server. Currently only the http validation method is supported. Provide the path to your `wwwroot` for the specified domain.

```ruby
letsencrypt_certificate 'test.example.com' do
  crt      '/etc/ssl/test.example.com.crt'
  key      '/etc/ssl/test.example.com.key'
  method   'http'
  wwwroot  '/var/www'
end
```

In case your webserver needs an already existing certificate when installing a new server you will have a bootstrap problem. Webserver cannot start without certificate, but the certificate cannot be requested without the running webserver. To overcome this a self-signed certificate can be generated with the `letsencrypt_selfsigned` provider.

```ruby
letsencrypt_selfsigned 'test.example.com' do
  crt     '/etc/ssl/test.example.com.crt'
  key     '/etc/ssl/test.example.com.key'
end
```

A working example can be found in the included `acme_client` test cookbook.

Testing
-------
The kitchen includes a `boulder` server to run the integration tests with, so testing can run locally without interaction with the online API's.

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Thijs Houtenbos <thoutenbos@schubergphilis.com>
