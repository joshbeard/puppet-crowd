class crowd::facts (
  $ensure            = $::crowd::facts_ensure,
  $facter_dir        = $::crowd::facter_dir,
  $create_facter_dir = $::crowd::create_facter_dir,
) {

  case $ensure {
    'absent': { $file_ensure = 'absent' }
    default: { $file_ensure = 'file' }
  }

  if $create_facter_dir {
    # Ensure facter's external fact directory exists
    # https://docs.puppet.com/facter/3.5/custom_facts.html#external-facts
    # Not using a file resource to avoid stepping on toes and defined() is
    # parse-order dependent.
    exec { "crowd_${facter_dir}":
      command => "/bin/mkdir -p '${facter_dir}'",
      creates => $facter_dir,
      before  => File["${facter_dir}/crowd_facts.txt"],
    }
  }

  file { "${facter_dir}/crowd_facts.txt":
    ensure  => $file_ensure,
    content => "crowd_version=${::crowd::version}",
    mode    => '0444',
  }

}
