# puppet-crowd

[![Puppet Forge](http://img.shields.io/puppetforge/v/joshbeard/crowd.svg)](https://forge.puppetlabs.com/joshbeard/crowd)
[![Build Status](https://travis-ci.org/joshbeard/puppet-crowd.png?branch=master)](https://travis-ci.org/joshbeard/puppet-crowd)

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Usage](#usage)
    * [Defaults](#defaults)
    * [Examples](#examples)
4. [Reference](#reference)
5. [Development](#development)
6. [Authors and Contributors](#authors-and-contributors)

## Overview

This Puppet module is used to install and configure the crowd application.
Atlassian Crowd is a Single Sign-On (SSO) and Identity Management service.
https://www.atlassian.com/software/crowd/overview

This module was forked from
[https://github.com/actionjack/puppet-crowd](https://github.com/actionjack/puppet-crowd),
which appears to be dormant.

* Manages the installation of Atlassian Crowd via compressed archive
* Manages Crowd init script and service
* Manages user
* Manages Crowd's Java settings and initial database settings

After installation, you should access Crowd in your browser.  The default
port is '8095'.  Unfortunately, you'll need to step through the installation
wizard, providing a license key and some basic configuration.

## Prerequisites

Current dependencies are:

 * puppetlabs/stdlib
 * puppet/staging

A Java installation is also required.
[puppetlabs/java](https://forge.puppetlabs.com/puppetlabs/java) is recommended.

## Usage

### Examples

__Defaults:__

```puppet
class { 'crowd': }
```

__Using PostgreSQL database:__

```puppet
class { 'crowd':
  db           => 'postgres',
  dbuser       => 'crowd',
  dbpassword   => 'secret',
  dbserver     => 'localhost',
  iddb         => 'postgres',
  iddbuser     => 'crowdid',
  iddbpassword => 'secret',
  iddbserver   => 'localhost',
}
```

__Custom Installation:__

```puppet
class { 'crowd':
  installdir   => '/srv/crowd',
  homedir      => '/srv/local/crowd',
  java_home    => '/usr/java/latest',
  download_url => 'http://mirrors.example.com/atlassian/crowd',
  mysql_driver => 'http://mirrors.example.com/mysql/mysql-connector/mysql-connector-java-5.1.36.jar',
}
```


## Reference

### Class: `crowd`

#### Parameters

__`version`__

Default:  '2.11.1'

The version of Crowd to download and install.  MAJOR.MINOR.PATCH

Refer to [https://www.atlassian.com/software/crowd/download](https://www.atlassian.com/software/crowd/download)

__`extension`__

Default:  'tar.gz'

The file extension of the archive to download.  This should be `.tar.gz` or
`.zip`

__`product`__

Default:  'crowd'

The product name.  This is should be 'crowd'

__`installdir`__

Default:  '/opt/crowd'

The absolute base path to install Crowd to.  Within this path, Crowd will be
installed to a sub-directory that matches the version.  Something like
`atlassian-crowd-2.8.3-standalone`

__`homedir`__

Default:  '/var/local/crowd'

The home directory for the crowd user.

__`tomcat_port`__

Default: '8095'

The port that Crowd's Tomcat should listen on.

__`max_threads`__

Default:  '150'

For Crowd's Tomcat setings.

__`connection_timeout`__

Default:  '20000'

For Crowd's Tomcat setings.

__`accept_count`__

Default:  '100'

For Crowd's Tomcat setings.

__`min_spare_threads`__

Default:  '25'

For Crowd's Tomcat setings.

__`proxy`__

Default: {}

Optional proxy configuration for Crowd's Tomcat.  This is a hash of attributes
to pass to the Tomcat connector.  Something like the following:

```
proxy => {
  scheme    => 'https',
  proxyName => 'foo.example.com',
  proxyPort => '443',
}
```

__`manage_user`__

Default: true

Whether this module should manage the user or not.

__`manage_group`__

Default: true

Whether this module should manage the group or not.

__`user`__

Default:  'crowd'

The user to manage Crowd as.

__`group`__

Default:  'crowd'

The group to manage Crowd as.

__`uid`__

Default: undef

Optional specified UID to use if managing the user.

__`gid`__

Default: undef

Optional specified GID to use if managing the group.

__`shell`__

Default:  '/sbin/nologin' and '/usr/sbin/nologin' on Debian.

The shell that the `user` should have set, if this module is to manage the user.

__`password`__

Default:  '*'

A password for the user, if this module is managing the user.

__`download_driver`__

Default: true

Whether this module should be responsible for downloading the JDBC driver for
MySQL if `db` is set to `mysql`.

Refer to [https://confluence.atlassian.com/display/CROWD/MySQL](https://confluence.atlassian.com/display/CROWD/MySQL)
for more information.

__`mysql_driver`__

Default:  'http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.36/mysql-connector-java-5.1.36.jar'

If this module should download the JDBC driver for MySQL, this parameter
should be set to the URL to download the `.jar` file from.

__`download_url`__

Default:  'https://www.atlassian.com/software/crowd/downloads/binary/'

The base URL to download Crowd from.

__`java_home`__

Default:  '/usr/lib/jvm/java'

The absolute path to the Java installation to use.

__`jvm_xms`__

Default:  '256m'

Custom JVM settings for initial memory size.

__`jvm_xmx`__

Default:  '512m'

Custom JVM settings for maximum memory size.

__`jvm_permgen`__

Default:  '256m'

Custom JVM settings for permgen size.  You probably don't need to tune this.

__`jvm_opts`__

Default:  ''

Any custom JVM options to start Crowd with.

__`db`__

Default:  'mysql'

The database type to use.  The module supports either `mysql` or `postgres`

__`dbuser`__

Default:  'crowd'

The username for connecting to the database.

__`dbpassword`__

Default:  'crowd'

The database password.

__`dbserver`__

Default:  'localhost'

The server address for accessing the Crowd database.

__`dbname`__

Default:  'crowd'

The name of the Crowd database.

__`dbport`__

Default: undef

The port for accessing the database server.  Defaults to '5432' for Postgres
and '3306' for MySQL.

__`dbdriver`__

Default: undef

Defaults to `com.mysql.jdbc.Driver` when `db` is set to `mysql` and
`org.postgresql.Driver` when `db` is set to `postgres`


__`iddb`__

Default:  'mysql'

The type of database for the CrowdID database.

See [https://confluence.atlassian.com/display/CROWD/Installing+Crowd+and+CrowdID](https://confluence.atlassian.com/display/CROWD/Installing+Crowd+and+CrowdID)

__`iddbuser`__

Default:  'crowd'

The database username for the CrowdID database.

__`iddbpassword`__

Default:  'crowd'

The database password for the CrowdID database.

__`iddbserver`__

Default:  'localhost'

The address for the database server for the CrowdID database.

__`iddbname`__

Default:  'crowdid'

The name of the database for the CrowdID database.

__`iddbport`__

Default: undef

The port for accessing the CrowdID database server.  Defaults to '5432' for Postgres
and '3306' for MySQL.

__`iddbdriver`__

Default: undef

Defaults to `com.mysql.jdbc.Driver` when `db` is set to `mysql` and
`org.postgresql.Driver` when `db` is set to `postgres`

__`manage_service`__

Default: true

Whether this module should manage the service.

__`service_file`__

Default: $crowd::params::service_file

The absolute path to the service file.  For traditional sysV init systems, this
defaults to `/etc/init.d/crowd`.

For upstart init systems (Ubuntu < 15.04), this defaults to `/etc/init/crowd.conf`

For systemd (RedHat > 7), this defaults to `/usr/lib/systemd/system/crowd.service`

Refer to [manifests/params.pp](manifests/params.pp) for default values.

__`service_template`__

Default: $crowd::params::service_template

The template to use for the init system.  A template for systemd, upstart, and
sysV init is provided by this module.

__`service_mode`__

Default: $crowd::params::service_mode

The file mode of the init file.  SysV init defaults to executable while
Upstart and Systemd do not.

__`service_ensure`__

Default:  'running'

The service state.

__`service_enable`__

Default: true

Whether the service should start on boot.

__`service_provider`__

Default: undef

The provider to use for managing the service.  You probably don't need to set
this.

## Development

Please feel free to raise any issues here for bug fixes. We also welcome
feature requests. Feel free to make a pull request for anything and we make the
effort to review and merge. We prefer with tests if possible.

[Travis CI](https://travis-ci.org/joshbeard/puppet-crowd) is used for testing.

### How to test the Crowd module

Install the dependencies:
```shell
bundle install
```

Unit tests:

```shell
bundle exec rake spec
```

Syntax validation:

```shell
bundle exec rake validate
```

Puppet Lint:

```shell
bundle exec rake lint
```

## Authors and Contributors

* Refer to the [CONTRIBUTORS](CONTRIBUTORS) file.
* Original module by [@actionjack](https://github.com/actionjack/puppet-crowd)
* Josh Beard (<josh@signalboxes.net>) [https://github.com/joshbeard](https://github.com/joshbeard)
