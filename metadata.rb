name             'letsencrypt'
maintainer       'Thijs Houtenbos'
maintainer_email 'thoutenbos@schubergphilis.com'
license          'All rights reserved'
description      'Install free and trusted SSL/TLS certificates from Let\'s Encrypt'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/schubergphilis/letsencrypt' if respond_to?(:source_url)
issues_url       'https://github.com/schubergphilis/letsencrypt/issues' if respond_to?(:issues_url)
version          '1.0.2'
