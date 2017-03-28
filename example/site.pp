node 'default' {
    # java needs to be installed in /opt/java, 1.8 preferred
    
    # puppet-nginx
    class { 'nginx': }
    nginx::resource::server {'192.168.56.102':
        listen_port => 80,
        proxy       => 'http://localhost:8095',
    }

    # puppet-crowd
    class { 'crowd':
        version    => '2.11.1',
        db         => 'mssql',
        dbserver   => '192.168.56.101',
        iddb       => 'mssql',
        iddbserver => '192.168.56.101',
        homedir    => '/opt/crowd/crowd-home',
        password   => 'crowd',
        java_home  => '/opt/java',
       
    }
}
