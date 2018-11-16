# Class crowd::config
#
class crowd::config {
  $changes = [
    "set Server/Service/Connector/#attribute/maxThreads '${crowd::max_threads}'",
    "set Server/Service/Connector/#attribute/minSpareThreads '${crowd::min_spare_threads}'",
    "set Server/Service/Connector/#attribute/connectionTimeout '${crowd::connection_timeout}'",
    "set Server/Service/Connector/#attribute/port '${crowd::tomcat_port}'",
    "set Server/Service/Connector/#attribute/acceptCount '${crowd::accept_count}'",
  ]

  if !empty($crowd::proxy) {
    $_proxy   = suffix(prefix(join_keys_to_values($crowd::proxy, " '"), 'set Server/Service/Connector/#attribute/'), "'")
    $_changes = concat($changes, $_proxy)
  }
  else {
    $_proxy   = undef
    $_changes = $changes
  }

  file { "${crowd::app_dir}/apache-tomcat/conf/server.xml":
    content => template('crowd/server.xml.erb'),
    owner   => $crowd::user,
    group   => $crowd::group,
  }
  
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

  file { "${crowd::app_dir}/apache-tomcat/conf/logging.properties":
    content => template('crowd/logging.properties.erb'),
    owner   => $crowd::user,
    group   => $crowd::group,
  }

  file { "${crowd::app_dir}/crowd-webapp/WEB-INF/classes/log4j.properties":
    content => template('crowd/log4j.properties.erb'),
    owner   => $crowd::user,
    group   => $crowd::group,
  }

  file { "${crowd::app_dir}/crowd-openidserver-webapp/WEB-INF/classes/log4j.properties":
    content => template('crowd/openidserver-log4j.properties.erb'),
    owner   => $crowd::user,
    group   => $crowd::group,
  }


}
