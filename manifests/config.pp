# Class crowd::config
#
class crowd::config {
  include crowd
  $changes = [
    "set Server/Service/Connector/#attribute/maxThreads '${crowd::max_threads}'",
    "set Server/Service/Connector/#attribute/minSpareThreads '${crowd::min_spare_threads}'",
    "set Server/Service/Connector/#attribute/connectionTimeout '${crowd::connection_timeout}'",
    "set Server/Service/Connector/#attribute/port '${crowd::tomcat_port}'",
    "set Server/Service/Connector/#attribute/acceptCount '${crowd::accept_count}'",
  ]

  if !empty($crowd::proxy) {
    $_proxy_changes   = suffix(prefix(join_keys_to_values($crowd::proxy, " '"), 'set Server/Service/Connector/#attribute/'), "'")
  } else {
    $_proxy_changes   = undef
  }

  if $crowd::manage_logging {
    $_valve_base = '/Server/Service/Engine/Valve[#attribute/className="org.apache.catalina.valves.AccessLogValves"]/#attribute'
    $_log_valve_changes = [
      "set ${_valve_base}/className 'org.apache.catalina.valves.AccessLogValves'",
      "set ${_valve_base}/maxDays '${crowd::log_max_days}'",
      "set ${_valve_base}/directory '${crowd::log_dir}'",
      "set ${_valve_base}/prefix 'localhost_access_log'",
      "set ${_valve_base}/suffix '.log'",
      "set ${_valve_base}/pattern '%t %{User-Agent}i %h %m %r %b %s %I %{X-AUSERNAME}o'",
    ]

    file_line { 'crowd_catalina_log_dir':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "1catalina.org.apache.juli.AsyncFileHandler.directory = ${crowd::log_dir}",
      match => '^1catalina.org.apache.juli.AsyncFileHandler.directory =',
    }
    file_line { 'crowd_catalina_log_max_days':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "1catalina.org.apache.juli.AsyncFileHandler.maxDays = ${crowd::log_max_days}",
      match => '^1catalina.org.apache.juli.AsyncFileHandler.maxDays =',
    }

    file_line { 'crowd_localhost_log_dir':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "2localhost.org.apache.juli.AsyncFileHandler.directory = ${crowd::log_dir}",
      match => '^2localhost.org.apache.juli.AsyncFileHandler.directory =',
    }
    file_line { 'crowd_localhost_log_max_days':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "2localhost.org.apache.juli.AsyncFileHandler.maxDays = ${crowd::log_max_days}",
      match => '^2localhost.org.apache.juli.AsyncFileHandler.maxDays =',
    }

    file_line { 'crowd_manager_log_dir':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "3manager.org.apache.juli.AsyncFileHandler.directory = ${crowd::log_dir}",
      match => '^3manager.org.apache.juli.AsyncFileHandler.directory =',
    }
    file_line { 'crowd_manager_log_max_days':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "3manager.org.apache.juli.AsyncFileHandler.maxDays = ${crowd::log_max_days}",
      match => '^3manager.org.apache.juli.AsyncFileHandler.maxDays =',
    }

    file_line { 'crowd_hostmanager_log_dir':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "4host-manager.org.apache.juli.AsyncFileHandler.directory = ${crowd::log_dir}",
      match => '^4host-manager.org.apache.juli.AsyncFileHandler.directory =',
    }
    file_line { 'crowd_hostmanager_log_max_days':
      path  => "${crowd::app_dir}/apache-tomcat/conf/logging.properties",
      line  => "4host-manager.org.apache.juli.AsyncFileHandler.maxDays = ${crowd::log_max_days}",
      match => '^4host-manager.org.apache.juli.AsyncFileHandler.maxDays =',
    }

    file_line { 'crowd_log4j_appender_log':
      path  => "${crowd::app_dir}/crowd-webapp/WEB-INF/classes/log4j.properties",
      line  => "log4j.appender.crowdlog.File=${crowd::log_dir}/atlassian-crowd.log",
      match => '^log4j.appender.crowdlog.File='
    }

    file_line { 'crowd_openidserver_log4j_appender_log':
      path  => "${crowd::app_dir}/crowd-openidserver-webapp/WEB-INF/classes/log4j.properties",
      line  => "log4j.appender.filelog.File=${crowd::log_dir}/atlassian-crowd-openid-server.log",
      match => '^log4j.appender.filelog.File='
    }

  }
  else {
    $_log_valvue_changes = undef
  }

  if $crowd::tomcat_address {
    $_address_changes = [
      "set Server/Service/Connector/#attribute/address '${crowd::tomcat_address}'",
    ]
  } else {
    $_address_changes = []
  }

  $_changes = concat($changes, $_proxy_changes, $_log_valve_changes, $_address_changes)

  augeas { "${crowd::app_dir}/apache-tomcat/conf/server.xml":
    lens    => 'Xml.lns',
    incl    => "${crowd::app_dir}/apache-tomcat/conf/server.xml",
    changes => $_changes,
  }

  file { "${crowd::app_dir}/apache-tomcat/bin/setenv.sh":
    ensure  => 'file',
    content => template('crowd/setenv.sh.erb'),
    mode    => '0755',
    owner   => $crowd::user,
    group   => $crowd::group,
  }

  file { "${crowd::app_dir}/crowd-webapp/WEB-INF/classes/crowd-init.properties":
    content => template('crowd/crowd-init.properties.erb'),
    owner   => $crowd::user,
    group   => $crowd::group,
  }

  file { "${crowd::app_dir}/apache-tomcat/conf/Catalina/localhost/openidserver.xml":
    content => template('crowd/openidserver.xml.erb'),
    owner   => $crowd::user,
    group   => $crowd::group,
  }

  file { "${crowd::app_dir}/crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties":
    content => template('crowd/jdbc.properties.erb'),
    owner   => $crowd::user,
    group   => $crowd::group,
  }

}
