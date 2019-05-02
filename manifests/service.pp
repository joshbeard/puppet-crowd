# Class crowd::service
#
class crowd::service {
  include crowd::params
  $service_provider = $crowd::params::service_provider

  file { 'crowd_service':
    ensure  => 'file',
    content => template($::crowd::service_template),
    path    => $crowd::service_file,
    mode    => $crowd::service_mode,
    owner   => 'root',
    group   => 'root',
  }

  if $crowd::manage_service {
    if $service_provider == 'systemd' {
      exec { 'crowd-refresh_systemd':
        command     => 'systemctl daemon-reload',
        refreshonly => true,
        path        => '/bin:/sbin:/usr/bin:/usr/sbin',
        subscribe   => File['crowd_service'],
        before      => Service['crowd'],
      }
    }

    service { 'crowd':
      ensure   => $crowd::service_ensure,
      enable   => $crowd::service_enable,
      provider => $crowd::service_provider,
    }
  }
}
