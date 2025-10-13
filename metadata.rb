name             'acme'
maintainer       'Thijs Houtenbos'
maintainer_email 'thoutenbos@schubergphilis.com'
license          'Apache-2.0'
description      'ACME client cookbook for free and trusted SSL/TLS certificates from Let\'s Encrypt'
source_url       'https://github.com/schubergphilis/chef-acme'
issues_url       'https://github.com/schubergphilis/chef-acme/issues'
version          '4.1.8'
chef_version     '>= 15.3'

%w(ubuntu debian redhat centos fedora).each do |os|
  supports os
end
