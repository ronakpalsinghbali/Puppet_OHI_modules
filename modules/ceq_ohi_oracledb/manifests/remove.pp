class eq_ohi_oracledb::remove (
) {

  case $facts['os']['family'] {
    'RedHat': {
      exec { 'remove nri-oracledb on RHEL':
        command => 'sudo yum remove -y nri-oracledb',
        path    => '/bin:/usr/bin',
        onlyif  => 'rpm -q nri-oracledb',
      }
      file { '/etc/newrelic-infra/integrations.d/oracledb-config.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }
}
