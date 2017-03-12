require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet_agent_on(hosts,options)
    end
  end
end

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
    puppet_module_install(:source => proj_root, :module_name => 'crowd')
    # net-tools required for netstat utility being used by be_listening
    if fact('osfamily') == 'RedHat' && fact('operatingsystemmajrelease') == '7'
      pp = <<-EOS
        package { 'net-tools': ensure => installed }
      EOS

      apply_manifest_on(agents, pp, :catch_failures => false)
    end

    hosts.each do |host|
      on host, "/bin/touch /etc/puppetlabs/code/hiera.yaml"
      on host, 'chmod 755 /root'
      if fact_on(host, 'osfamily') == 'Debian'
        on host, "echo \"en_US ISO-8859-1\nen_NG.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\n\" > /etc/locale.gen"
        on host, '/usr/sbin/locale-gen'
        on host, '/usr/sbin/update-locale'
      end

      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppet-staging'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-java'), { :acceptable_exit_codes => [0,1] }
    end
  end
end

# put local configuration and setup into spec_helper_acceptance_local
begin
  require 'spec_helper_acceptance_local'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end
