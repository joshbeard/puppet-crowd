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
        $service_file     = '/lib/systemd/system/crowd.service'
        $service_template = 'crowd/crowd.service.erb'
        $service_mode     = '0644'
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

  # Where to stick the external fact for reporting the version
  # Refer to:
  #   https://docs.puppet.com/facter/3.5/custom_facts.html#fact-locations
  #   https://github.com/puppetlabs/facter/commit/4bcd6c87cf00609f28be23f6463a3d76d0b6613c
  if versioncmp($::facterversion, '2.4.2') >= 0 {
    $facter_dir = '/opt/puppetlabs/facter/facts.d'
  }
  else {
    $facter_dir = '/etc/puppetlabs/facter/facts.d'
  }

  $stop_command = 'service crowd stop && sleep 10'

}
