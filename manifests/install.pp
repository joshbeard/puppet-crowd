# Class crowd::install
#
class crowd::install {

  $_download_url = regsubst($crowd::download_url, '\/$', '')
  $file = "atlassian-${crowd::product}-${crowd::version}.${crowd::extension}"
  $driver_file = basename($crowd::mysql_driver)
  $stop_command = $crowd::stop_command

  if $crowd::manage_user {
    user { $crowd::user:
      ensure           => 'present',
      comment          => 'Crowd service account',
      shell            => $crowd::shell,
      home             => $crowd::homedir,
      password         => $crowd::password,
      password_min_age => '0',
      password_max_age => '99999',
      managehome       => false,
      uid              => $crowd::uid,
      gid              => $crowd::gid,
    }
  }

  if $crowd::manage_group {
    group { $crowd::group:
      ensure => 'present',
      gid    => $crowd::gid,
    }
  }

  file { $crowd::installdir:
    ensure => 'directory',
    owner  => $crowd::user,
    group  => $crowd::group,
  }

  file { $crowd::app_dir:
    ensure => 'directory',
    owner  => $crowd::user,
    group  => $crowd::group,
  }

  file { $crowd::homedir:
    ensure => 'directory',
    mode   => '0750',
    owner  => $crowd::user,
    group  => $crowd::group,
  }

  # If the 'crowd_version' fact is defined (as provided by this module),
  # compare it to the specified version.  If it doesn't match, stop the
  # crowd service prior to upgrading but after downloading the new version
  if defined('$::crowd_version') {
    if versioncmp($::crowd::version, $::crowd_version) > 0 {
      notify { "Updating Crowd from version ${::crowd_version} to ${::crowd::version}": }
      exec { 'stop crowd for update':
        command => $stop_command,
        path    => $::path,
        require => Archive[$file],
        before  => Archive[$file],
      }
    }
  }

  archive { $file:
    source          => "${_download_url}/${file}",
    path            => "/tmp/$file",
    extract         => true,
    extract_command => 'tar xzf %s --strip-components=1',
    extract_path    => $crowd::app_dir,
    cleanup         => true,
    proxy_server    => $crowd::internet_proxy,
    allow_insecure  => true,
    creates         => "${crowd::app_dir}/apache-tomcat",
    user            => $crowd::user,
    group           => $crowd::group,
    require         => File[$crowd::app_dir],
  }

  file { $crowd::logdir:
    ensure => 'directory',
    owner  => $crowd::user,
    group  => $crowd::group,
  }

  file { "${crowd::homedir}/logs":
    ensure => 'directory',
    owner  => $crowd::user,
    group  => $crowd::group,
  }

  if $crowd::db == 'mysql' {
    if $crowd::download_driver {
      archive { 'jdbc driver':
        source       => $crowd::mysql_driver,
        path         => "${crowd::app_dir}/apache-tomcat/lib/${driver_file}",
        extract      => false,
        cleanup      => false,
        proxy_server => $crowd::internet_proxy,
        before       => Exec["chown_${crowd::app_dir}"],
      }
    }
  }

  exec { "chown_${crowd::app_dir}":
    command   => "chown -R ${crowd::user}:${crowd::group} ${crowd::app_dir}",
    unless    => "find ${crowd::app_dir} ! -type l \\( ! -user ${crowd::user} -type f \\) -o \\( ! -group ${crowd::group} \\) -a \\( -type f \\)| wc -l | awk '{print \$1}' | grep -qE '^0'",
    path      => '/bin:/usr/bin',
    require   => Archive[$file],
  }

}
