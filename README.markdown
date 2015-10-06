# Atlassian Crowd Puppet Module

[![Build Status](https://travis-ci.org/joshbeard/puppet-crowd.png?branch=master)](https://travis-ci.org/joshbeard/puppet-crowd)

 This puppet module is used to install and configure the crowd application.
 Atlassian Crowd is a Single Sign-On (SSO) and Identity Management service.
 https://www.atlassian.com/software/crowd/overview

 Forked from [https://github.com/actionjack/puppet-crowd](https://github.com/actionjack/puppet-crowd)

* * *

## Configuration


## Dependencies

Current dependencies are:

 * puppetlabs/stdlib
 * nanliu/staging or puppetcommunity/staging

## Usage

```ruby
class {'crowd': }
```

## Documentation

 This module is written in puppetdoc compliant format so details on
 configuration and usage can be found by executing:

```bash
$ puppet doc manifest/init.pp
```

## Pull Requests

 * Please submit a pull request or issue on
   [GitHub](https://github.com/joshbeard/puppet-crowd)

## Limitations

 This module has been built on and tested against Puppet 4.0 and higher.

 The module has been tested on:

 * EL 6
 * EL 7

 The module has been tested against the following database(s):

 * MySQL
 * Oracle
