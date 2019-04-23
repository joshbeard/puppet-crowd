require 'spec_helper'

describe 'crowd' do
  describe 'crowd::facts' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context "on #{os}" do
          context "crowd::facts class with default parameters" do
            let(:params) {{ }}
            let(:facts) do
              facts
            end

            ['2.4.2', '3.4.1'].each do |facter_version|
              context "with facter version #{facter_version}" do
                let(:facts) do
                  facts.merge({
                    :facterversion => facter_version
                  })
                end

                it do
                  is_expected.to contain_exec('crowd_/opt/puppetlabs/facter/facts.d').with({
                    :command => "/bin/mkdir -p '/opt/puppetlabs/facter/facts.d'",
                    :creates => '/opt/puppetlabs/facter/facts.d',
                  })
                end

                it do
                  is_expected.to contain_file('/opt/puppetlabs/facter/facts.d/crowd_facts.txt').with({
                    :ensure => 'file',
                    :content => /^crowd_version=2\.11\.1$/,
                  })
                end
              end
            end

            context "with facter < 2.4.2" do
              let(:facts) do
                facts.merge({
                  :facterversion => '2.4.1'
                })
              end

              it do
                is_expected.to contain_exec('crowd_/etc/puppetlabs/facter/facts.d').with({
                  :command => "/bin/mkdir -p '/etc/puppetlabs/facter/facts.d'",
                  :creates => '/etc/puppetlabs/facter/facts.d',
                })
              end
              it do
                is_expected.to contain_file('/etc/puppetlabs/facter/facts.d/crowd_facts.txt').with({
                  :ensure => 'file',
                  :content => /^crowd_version=3\.4\.3$/,
                })
              end
            end
          end
        end
      end
    end
  end
end
