# Class crowd::params
#
class crowd::params {

  case $::osfamily {
    'Redhat': {
      $shell = '/sbin/nologin'

      if $::operatingsystemmajrelease == '7' {
        $service_file     = '/usr/lib/systemd/system/crowd.service'
        $service_template = 'crowd/crowd.service.erb'
        $service_mode     = '0644'
      }
      else {
        $service_file     = '/etc/init.d/crowd'
        $service_template = 'crowd/crowd.init.erb'
        $service_mode     = '0755'
      }
    }

    'Debian': {
      $shell = '/usr/sbin/nologin'

      if $::operatingsystem == 'Ubuntu' {
        if $::operatingsystemmajrelease =~ /(12|14)/ {
          $service_file     = '/etc/init/crowd.conf'
          $service_template = 'crowd/crowd.upstart.erb'
          $service_mode     = '0644'
        }
        else {
          $service_file     = '/usr/lib/systemd/system/crowd.service'
          $service_template = 'crowd/crowd.service.erb'
          $service_mode     = '0644'
        }
      }
      else {
        $service_file     = '/etc/init.d/crowd'
        $service_template = 'crowd/crowd.init.erb'
        $service_mode     = '0755'
      }
    }

    'Windows': {
      fail('Windows is not supported')
    }

    default: {
      $shell            = '/sbin/nologin'
      $service_file     = '/etc/init.d/crowd'
      $service_template = 'crowd/crowd.init.erb'
      $service_mode     = '0755'
    }
  }

}
