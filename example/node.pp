node 'default' {
    class { 'crowd':
        version   => '2.11.0',
        db        => 'postgres',
    }
}
