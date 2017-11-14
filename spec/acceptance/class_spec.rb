require 'spec_helper_acceptance'

setup_manifest = <<-EOS
  if $::operatingsystemmajrelease == '16.04' {
    $java_home = "/usr/lib/jvm/java-8-openjdk-${::architecture}"
  } else {
    $java_home = $::osfamily ? {
      'RedHat' => '/etc/alternatives/java_sdk',
      'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
      default  => undef
    }
  }

  if !empty('#{CROWD_DOWNLOAD_URL}') {
    $download_url = '#{CROWD_DOWNLOAD_URL}'
    notice("CROWD_DOWNLOAD_URL is set. Using ${download_url}")
  } else {
    $download_url = undef
  }

  if !empty('#{CROWD_VERSION}') {
    $version = '#{CROWD_VERSION}'
    notice("CROWD_VERSION is set. Using ${version}")
  } else {
    $version = undef
  }
EOS

describe 'crowd class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
        #{setup_manifest}
        class{'java':}->
        class { 'crowd':
          java_home    => $java_home,
          download_url => $download_url,
          version      => '2.9.5',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
      shell('sleep 10')
    end

    describe service('crowd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8095) do
      it { is_expected.to be_listening }
    end

    describe command('ps aux | grep -E "java.*atlassian-crowd-2\.9\.5.*Bootstrap start"') do
      its(:exit_status) { should eq 0 }
    end

  end

  context 'upgrading' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
        #{setup_manifest}
        class{'java':}->
        class { 'crowd':
          java_home    => $java_home,
          download_url => $download_url,
          version      => '3.0.1',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
      shell('sleep 10')


    end

    describe service('crowd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8095) do
      it { is_expected.to be_listening }
    end

    describe command('ps aux | grep -E "java.*atlassian-crowd-2\.11\.1.*Bootstrap start"') do
      its(:exit_status) { should eq 0 }
    end
  end
end
