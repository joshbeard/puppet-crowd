node 'default' {
	$java_home = '/opt/jdk_1.8'
	class java {
		version   => '1.8',
		java_home => ${java_home},
	}

	class crowd:
		version   => '2.11.0',
		java_home => ${java_home},
		db        => 'postgres',
	}
}
