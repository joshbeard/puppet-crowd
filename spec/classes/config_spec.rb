require 'spec_helper'

describe 'crowd::config' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
        context 'defaults' do

          let :pre_condition do
            "class { 'crowd': }"
          end
          it { is_expected.to contain_augeas('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/server.xml').with({
            :changes => [
              "set Server/Service/Connector/#attribute/maxThreads '150'",
              "set Server/Service/Connector/#attribute/minSpareThreads '25'",
              "set Server/Service/Connector/#attribute/connectionTimeout '20000'",
              "set Server/Service/Connector/#attribute/port '8095'",
              "set Server/Service/Connector/#attribute/acceptCount '100'",
            ],
          })}

          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/bin/setenv.sh').with({
            :content => /JAVA_HOME="\/usr\/lib\/jvm\/java"/,
          })}

          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/bin/setenv.sh').with({
            :content => /JAVA_OPTS="-Xms256m -Xmx512m  -XX:MaxPermSize=256m/,
          })}

          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/bin/setenv.sh').with({
            :content => /CATALINA_PID="\/opt\/crowd\/atlassian-crowd-2.11.1-standalone\/apache-tomcat\/work\/crowd.pid"/,
          })}


          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/crowd-webapp/WEB-INF/classes/crowd-init.properties').with({
            :content => /crowd\.home=\/var\/local\/crowd/,
          })}

          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
            :content => /username="crowd"/
          })}
          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
            :content => /driverClassName="com\.mysql\.jdbc\.Driver"/
          })}
          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
            :content => /url="jdbc:mysql:\/\/localhost:3306\/crowdid/
          })}
          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
            :content => /validationQuery="Select 1"/
          })}

          it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties').with({
            :content => /hibernate\.dialect=org\.hibernate\.dialect\.MySQL5InnoDBDialect/
          })}
        end

        context 'custom parameter' do
          describe 'tomcat config' do
            let :pre_condition do
              "class { 'crowd':
                max_threads        => '200',
                min_spare_threads  => '50',
                connection_timeout => '30000',
                tomcat_port        => '9090',
                accept_count       => '200',
                proxy              => {
                  'scheme'    => 'https',
                  'proxyName' => 'foo.example.com',
                  'proxyPort' => '443',
                }
              }"
            end
            it { is_expected.to contain_augeas('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/server.xml').with({
              :changes => [
                "set Server/Service/Connector/#attribute/maxThreads '200'",
                "set Server/Service/Connector/#attribute/minSpareThreads '50'",
                "set Server/Service/Connector/#attribute/connectionTimeout '30000'",
                "set Server/Service/Connector/#attribute/port '9090'",
                "set Server/Service/Connector/#attribute/acceptCount '200'",
                "set Server/Service/Connector/#attribute/scheme 'https'",
                "set Server/Service/Connector/#attribute/proxyName 'foo.example.com'",
                "set Server/Service/Connector/#attribute/proxyPort '443'",
              ],
            })}
          end

          describe 'java_home' do
            let :pre_condition do
              "class { 'crowd': java_home => '/path/to/java' }"
            end

            it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/bin/setenv.sh').with({
              :content => /JAVA_HOME="\/path\/to\/java"/,
            })}
          end

          describe 'jvm_opts' do
            let :pre_condition do
              "class { 'crowd': jvm_opts => '-Dfoo.bar' }"
            end

            it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/bin/setenv.sh').with({
              :content => /JAVA_OPTS="-Xms256m -Xmx512m -Dfoo\.bar -XX:MaxPermSize=256m/,
            })}
          end

          describe 'crowd home' do
            let :pre_condition do
              "class { 'crowd': homedir => '/home/crowd' }"
            end
            it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/crowd-webapp/WEB-INF/classes/crowd-init.properties').with({
              :content => /crowd\.home=\/home\/crowd/,
            })}
          end

          describe 'db user' do
            let :pre_condition do
              "class { 'crowd': dbuser => 'charlie', iddbuser => 'charlie' }"
            end
            it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
              :content => /username="charlie"/
            })}
          end

          describe 'postgres' do
            let :pre_condition do
              "class { 'crowd':
                db   => 'postgres',
                iddb => 'postgres',
              }"
            end
            it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
              :content => /driverClassName="org\.postgresql\.Driver"/
            })}
            it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
              :content => /url="jdbc:postgresql:\/\/localhost:5432\/crowdid/
            })}
            it { is_expected.not_to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/apache-tomcat/conf/Catalina/localhost/openidserver.xml').with({
              :content => /validationQuery="Select 1"/
            })}

            it { is_expected.to contain_file('/opt/crowd/atlassian-crowd-2.11.1-standalone/crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties').with({
              :content => /hibernate\.dialect=org\.hibernate\.dialect\.PostgreSQLDialect/
            })}
          end
        end
    end
  end
end
