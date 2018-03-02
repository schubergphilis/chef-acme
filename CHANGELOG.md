ACME Cookbook Changelog
==============

This file is used to list changes made in each version of the acme cookbook.

4.0.0
-----
The TLS-SNI-01 validation method has been removed as it is no longer supported by Let's Encrypt.

- borgified - Documentation fix
- ibaum - Override endpoint from provider
- jeffbyrnes - Removed support for TLS-SNI-01 validation
- jeffbyrnes - Refactor LWRPs into Custom Resources
- jeffbyrnes - Foodcritic, cookstyle and build improvements
- thoutenbos - Upgrade acme-client gem to v0.6.2

3.1.0
-----
- axos88 - Add ssl validation method
- notapatch - Update README
- funzoneq - Extra validation server IP
- faucct - Remove unknown attribute validation 'min'
- faucct - Make sure nginx reloads
- wndhydrnt - Update certificate when common name / alternate names change

3.0.0
-----
By changes in Chef 13, the unused property `method` has been removed from the `certificate` provider.

- mattrobenolt - Do not allow a crt without an accompanying chain
- alex-tan - Improve README
- rmoriz - Allow setting custom key size
- szymonpk - Add missing matchers
- rmoriz - Chef 13 compatibility
- rmoriz - Multiple CI build improvements

2.0.0
-----
- thoutenbos - Rename from `letsencrypt` to `acme` to comply with the ISRG trademark policy
- arr-dev - Add ChefSpec matchers

1.0.3
-----
- chr4 - Bump versions of json-jwt and acme-client
- thoutenbos - Upgrade acme-client to drop dependencies

1.0.2
-----
- miguelaferreira - Wrap test cookbooks in :integration group

1.0.1
-----
- thoutenbos - Work around gem dependency problems
- thoutenbos - Rubocop fixes
- thoutenbos - Improve the example

1.0.0
-----
- seccubus - Make production the default end-point
- seccubus - Add apache2 example
- thoutenbos - Fix for chef-client v11 compatibility
- thoutenbos - Fix integration tests

0.1.7
-----
- glaszig - Use chef api inside ruby_block
- arr-dev - Document `node['letsencrypt']['private_key']`

0.1.6
-----
- funzoneq - Add verification IP for firewalling purposes
- acoulton - fail chef run if certificate not issued, unless `ignore_failure` resource attribute set

0.1.5
-----
- thoutenbos - fix selfsigned chain

0.1.4
-----
- patcon - spin-off the boulder test cookbook
- patcon - add Ubuntu support
- thoutenbos - various improvements

0.1.3
-----
- sawanoboly - Add SAN support

0.1.2
-----
- obazoud - Improved logging
- thoutenbos - Add Kitchen CI
- thoutenbos - Fix key/cert creation order issue

0.1.1
-----
- Thijs Houtenbos - Added `chain` and `fullchain` properties

0.1.0
-----
- Thijs Houtenbos - Initial release

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
