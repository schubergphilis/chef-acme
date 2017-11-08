name             'acme'
maintainer       'Thijs Houtenbos'
maintainer_email 'thoutenbos@schubergphilis.com'
license          'Apache-2.0'
description      'ACME client cookbook for free and trusted SSL/TLS certificates from Let\'s Encrypt'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/schubergphilis/chef-acme' if respond_to?(:source_url)
issues_url       'https://github.com/schubergphilis/chef-acme/issues' if respond_to?(:issues_url)
version          '3.1.1'
chef_version     '>= 12.1' if respond_to?(:chef_version)

depends 'compat_resource', '>= 12.19'
