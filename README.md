# puppet-crowd

[![Puppet Forge](http://img.shields.io/puppetforge/v/joshbeard/crowd.svg)](https://forge.puppetlabs.com/joshbeard/crowd)
[![Build Status](https://travis-ci.org/joshbeard/puppet-crowd.png?branch=master)](https://travis-ci.org/joshbeard/puppet-crowd)

- [puppet-crowd](#puppet-crowd)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
    - [Examples](#examples)
  - [Reference](#reference)
    - [Class: `crowd`](#class-crowd)
      - [Parameters](#parameters)
  - [Development](#development)
    - [How to test the Crowd module](#how-to-test-the-crowd-module)
  - [Authors and Contributors](#authors-and-contributors)

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
 * puppet/archive

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

Default:  '3.4.3'

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
`atlassian-crowd-2.8.3-standalone`.  You can override this sub-directory by
setting the 'appdir' parameter

__`appdir`__

Default: atlassian-${product}-${version}-standalone

The sub-directory under installdir to install Crowd to.

__`internet_proxy`__

Default: undef

Proxy setting to use if downloading Crowd behind a proxy.

__`homedir`__

Default:  '/var/local/crowd'

The home directory for the crowd user.

__`manage_logging`__

Default: false

If true, the module will manage the access log valve in the Crowd server's Tomcat server.xml, properties in `conf/logging.properties`,
properties in `crowd-webapp/WEB-INF/classes/log4j.properties`, and properties in `crowd-openidserver-webapp/WEB-INF/classes/log4j.properties`.

__`log_dir`__

Default: undef

If `manage_logging` is true, this should specify the absolute path to the log directory (e.g. `/var/log/crowd`).

__`manage_log_dir`__

Default: false

If `manage_logging` is true, this will manage the log directory via a `file` resource.

__`log_dir_owner`__

Default: `$user`

If `manage_log_dir` is true, this specifies the owner for the file resource.

__`log_dir_group`__

Default: `$group`

If `manage_log_dir` is true, this specifies the group for the file resource.

__`log_dir_mode`__

Default: `0750`

If `manage_log_dir` is true, this specifies the mode for the file resource.

__`log_max_days`__

Default: `5`

If `manage_logging` is true, this specifies the number of days to retain logs.

__`tomcat_port`__

Default: '8095'

The port that Crowd's Tomcat should listen on.

__`tomcat_address`__

Default: undef

The value for the 'address' attribute on the Tomcat connector.

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

Custom JVM settings for initial memory size. Set in `setenv.sh` in `CATALINA_OPTS`.

__`jvm_xmx`__

Default:  '512m'

Custom JVM settings for maximum memory size. Set in `setenv.sh` in `CATALINA_OPTS`.

__`jvm_permgen`__

Default:  '256m'

Custom JVM settings for permgen size.  You probably don't need to tune this.

__`jvm_opts`__

Default:  ''

Any custom JVM options to start Crowd with. Set in `setenv.sh` in `CATALINA_OPTS`.

__`logdir`__

Default:  '`/var/log/crowdir`'

Set the folder to store log files in.


__`db`__

Default:  'mysql'

The database type to use.  The module supports either `mysql`, `postgres`, or `oracle`.

__`dbuser`__

Default:  'crowd'

The username for connecting to the database.

__`dbpassword`__

Default:  'crowd'

The database password.

NOTE: This doesn't do anything.

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
`org.postgresql.Driver` when `db` is set to `postgres` and
`oracle.jdbc.driver.OracleDriver` when `db is set to `oracle`.

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

__`facts_ensure`__

Default: 'present'

Valid values are 'present' or 'absent'

Will provide an _external fact_ called `crowd_version` with the installed
Crowd version.

Note: This installs to Facter's system-wide external facts directory (facts.d -
see the `facter_dir` parameter). A better solution to tracking the installed
version is needed that can work with a dynamic install path.

__`facter_dir`__

Default: See [bamboo::params](manifests/params.pp)

Absolute path to the external facts directory. Refer to
[https://docs.puppet.com/facter/latest/custom_facts.html#external-facts](https://docs.puppet.com/facter/3.4/custom_facts.html#external-facts)

__`create_facter_dir`__

Default: true

Boolean

Whether this module should ensure the "facts.d" directory for external facts
is created.  This module uses an `Exec` resource to do that recursively if
this is true.

__`stop_command`__

Default: `service crowd stop && sleep 15`

The command to execute prior to upgrading.  This should stop any running
Crowd instance.  This is executed _after_ downloading the specified version
and _before_ extracting it to install it.

This requires `crowd::facts_ensure = true`.

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
