name             'acme'
maintainer       'Thijs Houtenbos'
maintainer_email 'thoutenbos@schubergphilis.com'
license          'Apache-2.0'
description      'ACME client cookbook for free and trusted SSL/TLS certificates from Let\'s Encrypt'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/schubergphilis/chef-acme' if respond_to?(:source_url)
issues_url       'https://github.com/schubergphilis/chef-acme/issues' if respond_to?(:issues_url)
version          '4.1.1'
chef_version     '>= 13.9' if respond_to?(:chef_version)

%w(ubuntu debian redhat centos fedora).each do |os|
  supports os
end
