class eq_ohi_jmx::remove (
) {
  case $facts['os']['family'] {
    'Debian': {
      exec { 'remove nri-jmx':
        command => 'sudo apt remove --purge nri-jmx -y',
        path    => '/bin:/usr/bin',
        onlyif  => 'dpkg -l | grep nri-jmx',
      }
      exec { 'remove nrjmx':
        command => 'sudo apt remove --purge nrjmx -y',
        path    => '/bin:/usr/bin',
        onlyif  => 'dpkg -l | grep nrjmx',
      }
      file { '/etc/newrelic-infra/integrations.d/jmx-config.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/jvm-metrics.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/tomcat-metrics.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
    }
    'RedHat': {
      # RedHat-specific removal
      exec { 'remove nri-jmx on RHEL':
        command => 'sudo yum remove -y nri-jmx',
        path    => '/bin:/usr/bin',
        onlyif  => 'rpm -q nri-jmx',
      }
      exec { 'remove nrjmx on RHEL':
        command => 'sudo yum remove -y nrjmx',
        path    => '/bin:/usr/bin',
        onlyif  => 'rpm -q nrjmx',
      }
      file { '/etc/newrelic-infra/integrations.d/jmx-config.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/jvm-metrics.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/tomcat-metrics.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
    }
    'windows': {
      # Windows-specific removal
      exec { 'uninstall nri-jmx':
        command => 'powershell.exe -Command "Get-WmiObject -Query \'SELECT * FROM Win32_Product WHERE Name = \"New Relic Infrastructure Integration, nri-jmx\"\' | ForEach-Object { $_.Uninstall() }"',
        path    => 'C:/Windows/System32/WindowsPowerShell/v1.0',
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d/jmx-win-config.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d/jvm-metrics.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }
}
