class { 'crowd':
  db    => 'postgres',
  iddb  => 'postgres',
  proxy => {
    'scheme'    => 'https',
    'proxyName' => 'foo.example.com',
    'proxyPort' => '443',
  }
}
