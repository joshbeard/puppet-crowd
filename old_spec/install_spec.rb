require 'spec_helper'

describe 'crowd::install' do

  context 'defaults' do
    let(:facts) { facts }
    let :pre_condition do
      "class { 'crowd': }"
    end
    it { is_expected.to contain_user('crowd').with({
      :shell    => '/sbin/nologin',
      :home     => '/var/local/crowd',
      :password => '*',
    })}

    it { is_expected.to contain_group('crowd') }

    it { is_expected.to contain_file('/opt/crowd') }
    it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.8.4-standalone') }
    it { is_expected.to contain_file('/var/local/crowd') }

    it { is_expected.to contain_staging__file('atlassian-crowd-2.8.4.tar.gz').with({
      :source => 'https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.8.4.tar.gz',
    })}

    it { is_expected.to contain_staging__extract('atlassian-crowd-2.8.4.tar.gz').with({
      :target  => '/opt/crowd/atlassian-crowd-2.8.4-standalone',
      :creates => '/opt/crowd/atlassian-crowd-2.8.4-standalone/apache-tomcat',
      :user    => 'crowd',
      :group   => 'crowd',
    })}

    it { is_expected.to contain_staging__file('jdbc driver').with({
      :source => 'http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.36/mysql-connector-java-5.1.36.jar',
      :target => '/opt/crowd/atlassian-crowd-2.8.4-standalone/apache-tomcat/lib/mysql-connector-java-5.1.36.jar',
    })}

    it { is_expected.to contain_exec('chown_/opt/crowd/atlassian-crowd-2.8.4-standalone').with({
      :command => 'chown -R crowd:crowd /opt/crowd/atlassian-crowd-2.8.4-standalone',
    })}
  end

  context 'custom parameters' do
    let(:facts) { facts }
    describe 'dont manager user or group' do
      let :pre_condition do
        "class { 'crowd':
          manage_user => false,
          manage_group => false,
        }"
      end

      it { is_expected.to_not contain_user('crowd') }
      it { is_expected.to_not contain_group('crowd') }
    end

    describe 'installdir' do
      let :pre_condition do
        "class { 'crowd': installdir => '/svr/crowd' }"
      end
      it { is_expected.to contain_file('/svr/crowd') }
      it { is_expected.to contain_file('/svr/crowd/atlassian-crowd-2.8.4-standalone') }
      it { is_expected.to contain_staging__extract('atlassian-crowd-2.8.4.tar.gz').with({
        :target => '/svr/crowd/atlassian-crowd-2.8.4-standalone',
        :creates => '/svr/crowd/atlassian-crowd-2.8.4-standalone/apache-tomcat',
      })}
    end

    describe 'homedir' do
      let :pre_condition do
        "class { 'crowd': homedir => '/home/crowd' }"
      end
      it { is_expected.to contain_file('/home/crowd') }
    end

    describe 'version' do
      let :pre_condition do
        "class { 'crowd': version => '2.8.4' }"
      end
      it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.8.4-standalone') }

      it { is_expected.to contain_staging__file('atlassian-crowd-2.8.4.tar.gz').with({
        :source => 'https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.8.4.tar.gz',
      })}

      it { is_expected.to contain_staging__extract('atlassian-crowd-2.8.4.tar.gz').with({
        :target => '/opt/crowd/atlassian-crowd-2.8.4-standalone',
        :creates => '/opt/crowd/atlassian-crowd-2.8.4-standalone/apache-tomcat',
      })}
    end

    describe 'postgres' do
      let :pre_condition do
        "class { 'crowd':
          db => 'postgres',
          iddb => 'postgres',
        }"
      end
      it { is_expected.not_to contain_staging__file('jdbc driver') }
    end

    describe 'mysql_driver using dns' do
      let :pre_condition do
        "class { 'crowd':
          mysql_driver => 'http://mirror.foo.com/mysql-connector-java.jar',
        }"
      end
      it { is_expected.to contain_staging__file('jdbc driver').with({
        :source => 'http://mirror.foo.com/mysql-connector-java.jar',
      })}
    end

    describe 'mysql_driver using ip and port' do
      let :pre_condition do
        "class { 'crowd':
          mysql_driver => 'http://192.168.0.0.1:8080/mysql-connector-java.jar',
        }"
      end
      it { is_expected.to contain_staging__file('jdbc driver').with({
        :source => 'http://192.168.0.0.1:8080/mysql-connector-java.jar',
      })}
    end

    describe 'download_url using dns' do
      let :pre_condition do
        "class { 'crowd':
          download_url => 'http://192.168.0.0.1:8080/',
        }"
      end
      it { is_expected.to contain_staging__file('atlassian-crowd-2.8.4.tar.gz').with({
        :source => 'http://192.168.0.0.1:8080/atlassian-crowd-2.8.4.tar.gz',
      })}
    end

    describe 'download_url from ip and port' do
      let :pre_condition do
        "class { 'crowd':
          download_url => 'http://192.168.0.0.1:8080/',
        }"
      end
      it { is_expected.to contain_staging__file('atlassian-crowd-2.8.4.tar.gz').with({
        :source => 'http://192.168.0.0.1:8080/atlassian-crowd-2.8.4.tar.gz',
      })}
    end

    describe 'download_driver false' do
      let :pre_condition do
        "class { 'crowd': download_driver => false }"
      end
      it { is_expected.not_to contain_staging__file('jdbc driver') }
    end
  end

end
