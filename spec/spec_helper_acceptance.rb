require 'beaker-pe'
require 'beaker-puppet'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
configure_type_defaults_on(hosts)
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)

# if these environment variables are set, pass them as class parameters for
# our tests (e.g. use a locally hosted crowd tarball)
CROWD_DOWNLOAD_URL = ENV['CROWD_DOWNLOAD_URL'] || nil
CROWD_VERSION = ENV['CROWD_VERSION'] || nil

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(source: proj_root, module_name: 'crowd')
    # net-tools required for netstat utility being used by be_listening
    if fact('osfamily') == 'RedHat' && fact('operatingsystemmajrelease') == '7'
      pp = <<-EOS
        package { 'net-tools': ensure => installed }
      EOS

      apply_manifest_on(agents, pp, catch_failures: false)
    end

    hosts.each do |host|
      on host, '/bin/touch /etc/puppetlabs/code/hiera.yaml'
      on host, 'chmod 755 /root'
      if fact_on(host, 'osfamily') == 'Debian'
        on host, "echo \"en_US ISO-8859-1\nen_NG.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\n\" > /etc/locale.gen"
        on host, '/usr/sbin/locale-gen'
        on host, '/usr/sbin/update-locale'
        # Install sources for OpenJDK 8 on older distributions
        if fact_on(host, 'operatingsystem') == 'Ubuntu'
          on host, 'apt-get install -y software-properties-common'
          on host, 'add-apt-repository ppa:openjdk-r/ppa'
        end

        if fact_on(host, 'operatingsystemmajrelease') == '8'
          on host, 'echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list'
        end

        on host, 'apt-get update'
      end

      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppet-archive'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppetlabs-java'), acceptable_exit_codes: [0, 1]
    end
  end
end
