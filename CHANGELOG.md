letsencrypt changelog
==============

This file is used to list changes made in each version of the letsencrypt cookbook.

1.0.2
-----
miguelaferreira - Wrap test cookbooks in :integration group

1.0.1
-----
thoutenbos - Work around gem dependency problems
thoutenbos - Rubocop fixes
thoutenbos - Improve the example

1.0.0
-----
seccubus - Make production the default end-point
seccubus - Add apache2 example
thoutenbos - Fix for chef-client v11 compatibility
thoutenbos - Fix integration tests

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
