letsencrypt cookbook
=============

[![Build Status](https://travis-ci.org/schubergphilis/letsencrypt.svg)](https://travis-ci.org/schubergphilis/letsencrypt)
[![Cookbook Version](https://img.shields.io/cookbook/v/letsencrypt.svg)](https://supermarket.chef.io/cookbooks/letsencrypt)

Automatically get/renew free and trusted certificates from Let's Encrypt (letsencrypt.org).

Attributes
----------
### default
* `node['letsencrypt']['contact']` - Contact information, default empty. Set to `mailto:your@email.com`.
* `node['letsencrypt']['endpoint']` - ACME server endpoint, default `https://acme-staging.api.letsencrypt.org`. Set to `https://acme-v01.api.letsencrypt.org` for real certificates.
* `node['letsencrypt']['renew']` - Days before the certificate expires at which the certificate will be renewed, default `30`.
* `node['letsencrypt']['source_ips']` - IP addresses used by letsencrypt to verify the TLS certificates. This attribute is for firewall purposes. Allow these IPs for HTTP (tcp/80).

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

Providers
---------
### certificate
<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>cn</tt></td>
    <td>String</td>
    <td>The common name for the certificate</td>
    <td><tt>Name of the resource block</tt></td>
  </tr>
  <tr>
    <td><tt>alt_names</tt></td>
    <td>Array</td>
    <td>The SAN names for the certificate</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>crt</tt></td>
    <td>String</td>
    <td>File path to place the certificate</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>key</tt></td>
    <td>String</td>
    <td>File path to place the private key</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>chain</tt></td>
    <td>String</td>
    <td>File path to place the certificate chain</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>fullchain</tt></td>
    <td>String</td>
    <td>File path to place the certificate including the chain</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>owner</tt></td>
    <td>String</td>
    <td>Owner of the created files</td>
    <td><tt>root</tt></td>
  </tr>
  <tr>
    <td><tt>group</tt></td>
    <td>String</td>
    <td>Group of the created files</td>
    <td><tt>root</tt></td>
  </tr>
  <tr>
    <td><tt>method</tt></td>
    <td>String</td>
    <td>Validation method</td>
    <td><tt>http</tt></td>
  </tr>
  <tr>
    <td><tt>wwwroot</tt></td>
    <td>String</td>
    <td>Path to the wwwroot of the domain</td>
    <td><tt>/var/www</tt></td>
  </tr>
  <tr>
    <td><tt>ignore_failure</tt></td>
    <td>Boolean</td>
    <td>Whether to continue chef run if issuance fails</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>retries</tt></td>
    <td>Integer</td>
    <td>Number of times to catch exceptions and retry</td>
    <td><tt>0</tt></td>
  </tr>
  <tr>
    <td><tt>retry_delay</tt></td>
    <td>Integer</td>
    <td>Number of seconds to wait between retries</td>
    <td><tt>2</tt></td>
  </tr>
</table>

### selfsigned
<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>cn</tt></td>
    <td>String</td>
    <td>The common name for the certificate</td>
    <td><tt>Name of the resource block</tt></td>
  </tr>
  <tr>
    <td><tt>crt</tt></td>
    <td>String</td>
    <td>File path to place the certificate</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>chain</tt></td>
    <td>String</td>
    <td>File path to place the certificate chain</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>key</tt></td>
    <td>String</td>
    <td>File path to place the private key</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>owner</tt></td>
    <td>String</td>
    <td>Owner of the created files</td>
    <td><tt>root</tt></td>
  </tr>
  <tr>
    <td><tt>group</tt></td>
    <td>String</td>
    <td>Group of the created files</td>
    <td><tt>root</tt></td>
  </tr>
</table>

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
