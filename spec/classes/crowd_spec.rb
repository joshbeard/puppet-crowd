require 'spec_helper'

describe 'crowd' do

  context 'unsupported operating systems' do
    let(:facts) {{ :osfamily => 'Windows' }}
    it { expect { catalogue }.to raise_error(Puppet::Error, /not supported/) }
  end

  context 'supported operating system' do
    on_supported_os.each do |os, facts|
      context os do
        it { is_expected.to contain_class('crowd::install') }
        it { is_expected.to contain_class('crowd::config') }
        it { is_expected.to contain_class('crowd::service') }
      end
    end
  end

  context 'invalid parameters' do
    describe 'version' do
      let(:params) {{ :version => '2.8' }}
      it { expect { catalogue }.to raise_error(Puppet::Error, /does not match/) }
    end

    describe 'extension' do
      let(:params) {{ :extension => 'rar' }}
      it { expect { catalogue }.to raise_error(Puppet::Error, /does not match/) }
    end

    %w(manage_user manage_group service_enable manage_service download_driver).each do |bool|
      describe bool do
        let(:params) {{ bool => 'true' }}
        it { expect { catalogue }.to raise_error(Puppet::Error, /not a boolean/) }
      end
    end

    %w(installdir homedir shell java_home service_file).each do |path|
      describe path do
        let(:params) {{ path => 'foo' }}
        it { expect { catalogue }.to raise_error(Puppet::Error, /not an absolute path/) }
      end
    end

    %w(tomcat_port max_threads connection_timeout accept_count min_spare_threads uid gid dbport iddbport).each do |integer|
      describe integer do
        let(:params) {{ integer => 'invalid' }}
        it { expect { catalogue }.to raise_error(Puppet::Error, /Expected first argument to be an Integer/) }
      end
    end

    %w(download_url mysql_driver).each do |url|
      describe url do
        let(:params) {{ url => 'notvalid' }}
        it { expect { catalogue }.to raise_error(Puppet::Error, /does not match/) }
      end
    end

    %w(jvm_xms jvm_xmx jvm_permgen).each do |jvm|
      describe jvm do
        let(:params) {{ jvm => '512' }}
        it { expect { catalogue }.to raise_error(Puppet::Error, /does not match/) }
      end
    end

    %w(db iddb).each do |db|
      describe db do
        let(:params) {{ db => 'oracle' }}
        it { expect { catalogue }.to raise_error(Puppet::Error, /does not match/) }
      end
    end

    describe 'service_ensure' do
      let(:params) {{ :service_ensure => 'idunno' }}
      it { expect { catalogue }.to raise_error(Puppet::Error, /does not match/) }
    end

    describe 'service_template' do
      let(:params) {{ :service_template => 'invalid.erb' }}
      it { expect { catalogue }.to raise_error(Puppet::Error, /should be modulename/) }
    end

    %w(dbuser iddbuser).each do |user|
      describe user do
        let(:params) {{ user => 'not.valid' }}
        it { expect { catalogue }.to raise_error(Puppet::Error, /does not match/) }
      end
    end

    os, facts = on_supported_os.first
    %w(user group).each do |user|
      describe user do
        let(:facts){facts}
        let(:params) {{ user => 'iam.valid' }}
          it { is_expected.to compile }
      end
    end
  end
end
