require 'spec_helper'

describe 'crowd::service' do

  context 'with defaults' do
    on_supported_os.each do |os, facts|
      let :pre_condition do
        "class { 'crowd': }"
      end
      context "on #{os}" do
        let(:facts) do
          facts
        end

        describe "manages init service file" do

          case facts[:osfamily]
          when /Redhat/i
            if facts[:operatingsystemmajrelease] == '7'
              it { is_expected.to contain_file('crowd_service').with({
                :path => '/usr/lib/systemd/system/crowd.service',
              })}
            else
              it { is_expected.to contain_file('crowd_service').with({
                :path => '/etc/init.d/crowd',
              })}
            end
          when 'Debian'
            case facts[:operatingsystem]
            when 'Ubuntu'
              if facts[:operatingsystemmajrelease] =~ /^(12|14)/
                it { is_expected.to contain_file('crowd_service').with({
                  :path => '/etc/init/crowd.conf',
                })}
              else
                it { is_expected.to contain_file('crowd_service').with({
                  :path => '/usr/lib/systemd/system/crowd.service',
                })}
              end
            else
              it { is_expected.to contain_file('crowd_service').with({
                :path => '/etc/init.d/crowd',
              })}
            end
          else
            it { is_expected.to contain_file('crowd_service').with({
              :path => '/etc/init.d/crowd',
            })}
          end

        end

      end
    end

    describe "manages service" do
      it { is_expected.to contain_service('crowd').with({
        :ensure => 'running',
        :enable => true,
      })}
    end

  end

  context 'with custom parameters' do

    let(:facts) { facts }
    describe 'service file and mode' do
      let :pre_condition do
        "class { 'crowd':
            service_file     => '/tmp/foo.service',
            service_mode     => '0600',
          }"
      end

      it { is_expected.to contain_file('crowd_service').with({
        :path => '/tmp/foo.service',
        :mode => '0600',
      })}
    end

    describe 'dont manage service' do
      let :pre_condition do
        "class { 'crowd': manage_service => false }"
      end
      it { is_expected.not_to contain_service('crowd') }
    end

    describe 'service state' do
      let :pre_condition do
        "class { 'crowd':
              service_ensure => 'stopped',
              service_enable => false,
            }"
      end
      it { is_expected.to contain_service('crowd').with({
        :ensure => 'stopped',
        :enable => false,
      })}
    end

  end

end
