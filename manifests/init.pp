
# == Class: crowd
#
# Refer to the README for documentation
#
class crowd (
  $version                    = '2.11.1',
  $extension                  = 'tar.gz',
  $product                    = 'crowd',
  $installdir                 = '/opt/crowd',
  $homedir                    = '/var/local/crowd',
  $logdir                     = '/var/log/crowd',
  $tomcat_port                = '8095',
  $max_threads                = '150',
  $connection_timeout         = '20000',
  $accept_count               = '100',
  $min_spare_threads          = '25',
  $proxy                      = {},
  $manage_user                = true,
  $manage_group               = true,
  $manage_home                = false,
  $user                       = 'crowd',
  $group                      = 'crowd',
  $uid                        = undef,
  $gid                        = undef,
  $shell                      = $crowd::params::shell,
  $password                   = '*',
  $download_driver            = true,
  $mysql_driver               = 'http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.36/mysql-connector-java-5.1.36.jar',
  $download_url               = 'https://www.atlassian.com/software/crowd/downloads/binary/',
  $java_home                  = '/usr/lib/jvm/java',
  $jvm_xms                    = '256m',
  $jvm_xmx                    = '512m',
  $jvm_permgen                = '256m',
  $jvm_opts                   = '',
  $db                         = 'mysql',
  $dbuser                     = 'crowd',
  $dbpassword                 = 'crowd',
  $dbserver                   = 'localhost',
  $dbname                     = 'crowd',
  $dbport                     = undef,
  $dbdriver                   = undef,
  $iddb                       = 'mysql',
  $iddbuser                   = 'crowd',
  $iddbpassword               = 'crowd',
  $iddbserver                 = 'localhost',
  $iddbname                   = 'crowdid',
  $iddbport                   = undef,
  $iddbdriver                 = undef,
  # $iddbvalidationquery        = undef,
  $manage_service             = true,
  $service_file               = $crowd::params::service_file,
  $service_template           = $crowd::params::service_template,
  $service_mode               = $crowd::params::service_mode,
  $service_ensure             = 'running',
  $service_enable             = true,
  $service_provider           = undef,
  $facts_ensure               = 'present',
  $facter_dir                 = $crowd::params::facter_dir,
  $create_facter_dir          = true,
  $stop_command               = $crowd::params::stop_command,
) inherits crowd::params {

  validate_re($version, '^\d+\.\d+.\d+$')
  validate_re($extension, '^(tar\.gz|\.zip)$')
  validate_absolute_path($installdir)
  validate_absolute_path($homedir)
  validate_absolute_path($logdir)

  validate_integer($tomcat_port)
  validate_integer($max_threads)
  validate_integer($connection_timeout)
  validate_integer($accept_count)
  validate_integer($min_spare_threads)
  validate_hash($proxy)
  validate_bool($manage_user)
  validate_bool($manage_group)
  $_user_group_regex = '^[a-z_][a-z\.0-9_-]*[$]?$'
  validate_re($user, $_user_group_regex)
  validate_re($group, $_user_group_regex)

  if $uid { validate_integer($uid) }
  if $gid { validate_integer($gid) }

  validate_string($password)
  validate_absolute_path($shell)

  validate_re($download_url, '^((https?|ftps?|puppet?):\/\/\/?)(([\da-z\.-]+)\.?([a-z\.]{2,6})([\/\w \.-]*)*\/)??$')

  validate_bool($download_driver)
  if $db == 'mysql' {
    validate_re($mysql_driver, '^((https?|ftps?|puppet?):\/\/\/?)([\da-z\.-]+)\.?([\da-z\.]{2,6})([\/\w \.\:-]*)*\/?\.jar$')
  }

  validate_absolute_path($java_home)
  validate_re($jvm_xms, '\d+(m|g)$')
  validate_re($jvm_xmx, '\d+(m|g)$')
  validate_re($jvm_permgen, '\d+(m|g)$')

  if !empty($jvm_opts) { validate_string($jvm_opts) }

  validate_re($db, '^(mysql|postgres|mssql)$')
  validate_re($dbuser, '^[a-z_][a-z0-9_-]*[$]?$')
  validate_string($dbpassword)
  validate_string($dbserver)
  validate_string($dbname)
  if $dbport { validate_integer($dbport) }
  if $dbdriver { validate_string($dbdriver) }

  validate_re($iddb, '^(mysql|postgres|mssql)$')
  validate_re($iddbuser, '^[a-z_][a-z0-9_-]*[$]?$')
  validate_string($iddbpassword)
  validate_string($iddbserver)
  validate_string($iddbname)
  if $iddbport { validate_integer($iddbport) }
  if $iddbdriver { validate_string($iddbdriver) }

  validate_bool($manage_service)
  validate_absolute_path($service_file)
  validate_re($service_ensure, '(running|stopped)')
  validate_bool($service_enable)
  validate_re($service_template, '^(\w+)\/([\/\.\w\s]+)$',
    'service_template should be modulename/path/to/template.erb'
  )

  if $service_provider { validate_string($service_provider) }

  validate_re($facts_ensure, '(present|absent)')
  validate_absolute_path($facter_dir)
  validate_bool($create_facter_dir)
  validate_string($stop_command)

  case $db {
    'mysql': {
      $_dbport = $dbport ? {
        undef   => '3306',
        default => $dbport,
      }
      $_dbdriver = $dbdriver ? {
        undef   => 'com.mysql.jdbc.Driver',
        default => $dbdriver,
      }
      $dbtype = 'mysql'
    }
    'postgres': {
      $_dbport = $dbport ? {
        undef   => '5432',
        default => $dbport,
      }
      $_dbdriver = $dbdriver ? {
        undef   => 'org.postgresql.Driver',
        default => $dbdriver,
      }
      $dbtype = 'postgresql'
    }
    'mssql': {
      $_dbport = $dbport ? {
        undef   => '1433',
        default => $dbport,
      }
      $_dbdriver = $dbdriver ? {
        undef   => 'net.sourceforge.jtds.jdbc.Driver',
        default => $dbdriver,
      }
      $dbtype = 'mssql'
    }
    default: {
      warning("db database type ${db} is not supported")
    }
  }

  case $iddb {
    'mysql': {
      $_iddbport = $iddbport ? {
        undef   => '3306',
        default => $iddbport,
      }
      $_iddbdriver = $iddbdriver ? {
        undef   => 'com.mysql.jdbc.Driver',
        default => $iddbdriver,
      }
      $iddbtype = 'mysql'
      $iddbvalidationquery = "Select 1"
    }
    'postgres': {
      $_iddbport = $iddbport ? {
        undef   => '5432',
        default => $iddbport,
      }
      $_iddbdriver = $iddbdriver ? {
        undef   => 'org.postgresql.Driver',
        default => $iddbdriver,
      }
      $iddbtype = 'postgresql'
      $iddbvalidationquery = "Select 1"
    }
    'mssql': {
      $_iddbport = $iddbport ? {
        undef   => '1433',
        default => $iddbport,
      }
      $_iddbdriver = $iddbdriver ? {
        undef   => 'net.sourceforge.jtds.jdbc.Driver',
        default => $iddbdriver,
      }
      $iddbtype = 'mssql'
      $iddbvalidationquery = "Select 1"
    }
    default: {
      $iddbvalidationquery = undef
      warning("iddb database type ${iddb} is not supported")
    }
  }

  $app_dir = "${installdir}/atlassian-${product}-${version}-standalone"
  $dburl   = "jdbc:${dbtype}://${dbserver}:${_dbport}/${dbname}"
  $iddburl = "jdbc:${iddbtype}://${iddbserver}:${_iddbport}/${iddbname}"

  anchor { 'crowd::begin': }->
  class { 'crowd::install': }->
  class { 'crowd::facts': }->
  class { 'crowd::config': }~>
  class { 'crowd::service': }->
  anchor { 'crowd::end': }

}
