letsencrypt cookbook
=============

[![Build Status](https://travis-ci.org/schubergphilis/letsencrypt.svg)](https://travis-ci.org/schubergphilis/letsencrypt)
[![Cookbook Version](https://img.shields.io/cookbook/v/letsencrypt.svg)](https://supermarket.chef.io/cookbooks/letsencrypt)

Automatically get/renew free and trusted certificates from Let's Encrypt (letsencrypt.org).

Attributes
----------
### default
* `node['letsencrypt']['contact']` - Contact information, default empty. Set to `mailto:your@email.com`.
* `node['letsencrypt']['endpoint']` - ACME server endpoint, default `https://acme-v01.api.letsencrypt.org`. Set to `https://acme-staging.api.letsencrypt.org` if you want to use the letsencrypt staging environment and corresponding certificates.
* `node['letsencrypt']['renew']` - Days before the certificate expires at which the certificate will be renewed, default `30`.
* `node['letsencrypt']['source_ips']` - IP addresses used by letsencrypt to verify the TLS certificates, it will change over time. This attribute is for firewall purposes. Allow these IPs for HTTP (tcp/80).
* `node['letsencrypt']['private_key']` - Private key content of registered account.

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
| Property         | Type    | Default  | Description                                            |
|  ---             |  ---    |  ---     |  ---                                                   |
| `cn`             | string  | _name_   | The common name for the certificate                    |
| `alt_names`      | array   | []       | The common name for the certificate                    |
| `crt`            | string  | nil      | File path to place the certificate                     |
| `key`            | string  | nil      | File path to place the private key                     |
| `chain`          | string  | nil      | File path to place the certificate chain               |
| `fullchain`      | string  | nil      | File path to place the certificate including the chain |
| `owner`          | string  | root     | Owner of the created files                             |
| `group`          | string  | root     | Group of the created files                             |
| `method`         | string  | http     | Validation method                                      |
| `wwwroot`        | string  | /var/www | Path to the wwwroot of the domain                      |
| `ignore_failure` | boolean | false    | Whether to continue chef run if issuance fails         |
| `retries`        | integer | 0        | Number of times to catch exceptions and retry          |
| `retry_delay`    | integer | 2        | Number of seconds to wait between retries              |

### selfsigned
| Property         | Type    | Default  | Description                                            |
|  ---             |  ---    |  ---     |  ---                                                   |
| `cn`             | string  | _name_   | The common name for the certificate                    |
| `crt`            | string  | nil      | File path to place the certificate                     |
| `key`            | string  | nil      | File path to place the private key                     |
| `chain`          | string  | nil      | File path to place the certificate chain               |
| `owner`          | string  | root     | Owner of the created files                             |
| `group`          | string  | root     | Group of the created files                             |

Example
-------
To generate a certificate for an apache2 website you can use code like this:

    # Include the recipe to install the gems
    include_recipe 'letsencrypt'

    # Set up contact information. Note the mailto: notation
    node.set['letsencrypt']['contact'] = [ 'mailto:me@example.com' ] 
    # Real certificates please...
    node.set['letsencrypt']['endpoint'] = 'https://acme-v01.api.letsencrypt.org' 

    site="example.com"
    sans=Array[ "www.#{site}" ]

    # Set up your server here...

    # Let's letsencrypt

    # Generate a self-signed if we don't have a cert to prevent bootstrap problems
    letsencrypt_selfsigned "#{site}" do
        crt     "/etc/httpd/ssl/#{site}.crt"
        key     "/etc/httpd/ssl/#{site}.key"
        chain    "/etc/httpd/ssl/#{site}.pem"
        owner   "apache"
        group   "apache"
        notifies :restart, "service[apache2]", :immediate
        not_if do
            # Only generate a self-signed cert if needed
            ::File.exists?("/etc/httpd/ssl/#{site}.crt")
        end
    end

    # Get and auto-renew the certificate from letsencrypt
    letsencrypt_certificate "#{site}" do
        crt      "/etc/httpd/ssl/#{site}.crt"
        key      "/etc/httpd/ssl/#{site}.key"
        chain    "/etc/httpd/ssl/#{site}.pem"
        method   "http"
        wwwroot  "/var/www/#{site}/htdocs/"
        notifies :restart, "service[apache2]"
        alt_names sans
    end

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
