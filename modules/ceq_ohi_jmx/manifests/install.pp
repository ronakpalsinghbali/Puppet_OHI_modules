class eq_ohi_jmx::install (
  Sensitive[String] $jmx_nr_user_password = Sensitive(''),
  String $jmx_nr_username = '',
  String $tomcat_domain = '',
  String $jvm_domain = '',
  String $jmx_port = '',
){

  case $facts['os']['family'] {
        'Debian': {
      # Debian-specific installation
      exec { 'install nri-jmx':
        command => 'sudo apt install nri-jmx -y',
        path    => '/bin:/usr/bin',
        unless  => 'dpkg -l | grep nri-jmx',
      }
      file { '/etc/newrelic-infra/integrations.d':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      file { '/etc/newrelic-infra/integrations.d/jmx-config.yml':
        ensure  => 'file',
        content => epp("${module_name}/jmx-config.yml.epp", {
          'username' => "${jmx_nr_username}",
          'password' => "${jmx_nr_user_password.unwrap}",
          'port'     => "${jmx_port}",
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/jvm-metrics.yml':
        ensure  => 'file',
        content => epp("${module_name}/jvm-metrics.yml.epp", {
          'domain' => "${jvm_domain}",
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/tomcat-metrics.yml':
        ensure  => 'file',
        content => epp("${module_name}/tomcat-metrics.yml.epp", {
          'domain' => "${tomcat_domain}",
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/jmx-config.yml.sample':
        ensure => 'absent',
      }
    }
    'RedHat': {
      # RedHat-specific installation 
      exec { 'install nri-jmx':
        command => 'sudo yum install nri-jmx -y',
        path    => '/bin:/usr/bin',
        unless  => 'rpm -q nri-jmx',
      }
      file { '/etc/newrelic-infra/integrations.d':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
            file { '/etc/newrelic-infra/integrations.d/jmx-config.yml':
        ensure  => 'file',
        content => epp("${module_name}/jmx-config.yml.epp", {
          'username' => "${jmx_nr_username}",
          'password' => "${jmx_nr_user_password.unwrap}",
          'port'     => "${jmx_port}",
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/jvm-metrics.yml':
        ensure  => 'file',
        content => epp("${module_name}/jvm-metrics.yml.epp", {
          'domain' => "${jvm_domain}",
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/tomcat-metrics.yml':
        ensure  => 'file',
        content => epp("${module_name}/tomcat-metrics.yml.epp", {
          'domain' => "${tomcat_domain}",
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
    }
    'windows': {
      # Windows-specific installation
      exec { 'download nri-jmx':
        command => 'powershell.exe -Command "Invoke-WebRequest -Uri https://download.newrelic.com/infrastructure_agent/windows/integrations/nri-jmx/nri-jmx-amd64.2.4.4.msi -OutFile C:\\Users\\Public\\Downloads\\nri-jmx-amd64.2.4.4.msi"',
        path    => 'C:/Windows/System32/WindowsPowerShell/v1.0',
        creates => 'C:\\Users\\Public\\Downloads\\nri-jmx-amd64.2.4.4.msi',
      }
      exec { 'install nri-jmx':
        command => 'msiexec.exe /qn /norestart /i C:\\Users\\Public\\Downloads\\nri-jmx-amd64.2.4.4.msi',
        path    => ['C:/Windows/System32', 'C:/Windows/System32/WindowsPowerShell/v1.0'],
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d':
        ensure => 'directory',
        owner  => 'Administrator',
        group  => 'Administrators',
        mode   => '0755',
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d/jmx-win-config.yml':
        ensure  => 'file',
        content => epp("${module_name}/jmx-win-config.yml.epp", {
          'username' => "${jmx_nr_username}",
          'password' => "${jmx_nr_user_password.unwrap}",
          'port'     => "${jmx_port}",
        }),
        owner   => 'Administrator',
        group   => 'Administrators',
        mode    => '0644',
        require => File['C:/Program Files/New Relic/newrelic-infra/integrations.d'],
        notify  => Service['newrelic-infra'],
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d/jvm-metrics.yml':
        ensure  => 'file',
        content => epp("${module_name}/jvm-metrics.yml.epp", {
          'domain' => "${jvm_domain}",
        }),
        owner   => 'Administrator',
        group   => 'Administrators',
        mode    => '0644',
        require => File['C:/Program Files/New Relic/newrelic-infra/integrations.d'],
        notify  => Service['newrelic-infra'],
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }
}
