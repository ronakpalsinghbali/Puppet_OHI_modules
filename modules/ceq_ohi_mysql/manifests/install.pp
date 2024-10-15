class eq_ohi_mysql::install (
  String $mysql_nr_username = '',
  Sensitive[String] $mysql_nr_user_password = Sensitive(''),
  Sensitive[String] $mysql_root_password = Sensitive(''),
){
  case $facts['os']['family'] {
    'windows': {
      exec { 'download nri-mysql':
        command => 'powershell.exe -Command "Invoke-WebRequest -Uri https://download.newrelic.com/infrastructure_agent/windows/integrations/nri-mysql/nri-mysql-amd64.1.9.0.msi -OutFile C:\\Users\\Public\\Downloads\\nri-mysql-amd64.1.9.0.msi"',
        path    => 'C:/Windows/System32/WindowsPowerShell/v1.0',
        creates => 'C:\\Users\\Public\\Downloads\\nri-mysql-amd64.1.9.0.msi',
      }
      exec { 'install nri-mysql':
        command => 'msiexec.exe /qn /norestart /i C:\\Users\\Public\\Downloads\\nri-mysql-amd64.1.9.0.msi',
        path    => ['C:/Windows/System32', 'C:/Windows/System32/WindowsPowerShell/v1.0'],
      }
      exec { 'create mysql user newrelic':
        command => "mysql -u root -p\"${mysql_root_password.unwrap}\" -e \"CREATE USER '${mysql_nr_username}'@'localhost' IDENTIFIED BY '${mysql_nr_user_password.unwrap}'; GRANT REPLICATION CLIENT ON *.* TO '${mysql_nr_username}'@'localhost'; GRANT SELECT ON *.* TO '${mysql_nr_username}'@'localhost';\"",
        path    => 'C:/Program Files/MySQL/MySQL Server 8.0/bin',
        unless  => "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command \"if (mysql.exe -u root -p'${mysql_root_password.unwrap}' -e \\\"SELECT User FROM mysql.user WHERE User = '${mysql_nr_username}' AND Host = 'localhost';\\\" | Select-String '${mysql_nr_username}') { exit 0 } else { exit 1 }\"",
      }
      # exec { 'create mysql user newrelic':
      #   command => "mysql.exe -u root -p\"${mysql_root_password.unwrap}\" -e \"CREATE USER IF NOT EXISTS '${mysql_nr_username}'@'localhost' IDENTIFIED BY '${mysql_nr_user_password.unwrap}'; GRANT REPLICATION CLIENT ON *.* TO '${mysql_nr_username}'@'localhost'; GRANT SELECT ON *.* TO '${mysql_nr_username}'@'localhost';\"",
      #   path    => 'C:/Program Files/MySQL/MySQL Server 8.0/bin',
      # }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d':
        ensure => 'directory',
        owner  => 'Administrator',
        group  => 'Administrators',
        mode   => '0755',
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d/mysql-config.yml':
        ensure  => 'file',
        content => epp("${module_name}/mysql-config.yml.epp", {
          'username' => "${mysql_nr_username}",
          'password' => "${mysql_nr_user_password.unwrap}",
        }),
        owner   => 'Administrator',
        group   => 'Administrators',
        mode    => '0644',
        require => File['C:/Program Files/New Relic/newrelic-infra/integrations.d'],
        notify  => Service['newrelic-infra'],
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/logs.d':
        ensure => 'directory',
        owner  => 'Administrator',
        group  => 'Administrators',
        mode   => '0755',
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/logging.d/mysql-log.yml':
        ensure  => 'file',
        content => epp("${module_name}/mysql-log.yml.epp", {
          'log_file' => 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/mysql_error.log', 
        }),
        owner   => 'Administrator',
        group   => 'Administrators',
        mode    => '0644',
        require => File['C:/Program Files/New Relic/newrelic-infra/logs.d'],
        notify  => Service['newrelic-infra'],
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d/mysql-config.yml.sample':
        ensure => 'absent',
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/logging.d/mysql-log.yml.example':
        ensure => 'absent',
      }
    }
    'RedHat': {
      # RedHat-specific installation 
      exec { 'create mysql user newrelic':
        command => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"CREATE USER '${mysql_nr_username}'@'localhost' IDENTIFIED BY '${mysql_nr_user_password.unwrap}'; GRANT REPLICATION CLIENT ON *.* TO '${mysql_nr_username}'@'localhost'; GRANT SELECT ON *.* TO '${mysql_nr_username}'@'localhost';\"",
        path    => '/usr/bin',
        unless  => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"SELECT User FROM mysql.user WHERE User='${mysql_nr_username}' AND Host='localhost';\" | grep ${mysql_nr_username}",
      }
      # exec { 'create mysql user newrelic':
      #   command => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"CREATE USER IF NOT EXISTS '${mysql_nr_username}'@'localhost' IDENTIFIED BY '${mysql_nr_user_password.unwrap}'; GRANT REPLICATION CLIENT ON *.* TO '${mysql_nr_username}'@'localhost'; GRANT SELECT ON *.* TO '${mysql_nr_username}'@'localhost';\"",
      #   path    => '/usr/bin',
      # }
      exec { 'install nri-mysql':
        command => 'sudo yum install nri-mysql -y',
        path    => '/bin:/usr/bin',
        unless  => 'rpm -q nri-mysql',
      }
      file { '/etc/newrelic-infra/integrations.d':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      file { '/etc/newrelic-infra/integrations.d/mysql-config.yml':
        ensure  => 'file',
        content => epp("${module_name}/mysql-config.yml.epp", {
          'username' => "${mysql_nr_username}",      
          'password' => "${mysql_nr_user_password.unwrap}",   
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/logging.d':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      file { '/etc/newrelic-infra/logging.d/mysql-log.yml':
        ensure  => 'file',
        content => epp("${module_name}/mysql-log.yml.epp", {
          'log_file' => '/var/log/mysql/error.log', 
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/logging.d'],
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/mysql-config.yml.sample':
        ensure => 'absent',
      }
      file { '/etc/newrelic-infra/logging.d/mysql-log.yml.example':
        ensure => 'absent',
      }
    }
    'Debian': {
      # Debian-specific installation
      exec { 'create mysql user newrelic':
        command => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"CREATE USER '${mysql_nr_username}'@'localhost' IDENTIFIED BY '${mysql_nr_user_password.unwrap}'; GRANT REPLICATION CLIENT ON *.* TO '${mysql_nr_username}'@'localhost'; GRANT SELECT ON *.* TO '${mysql_nr_username}'@'localhost';\"",
        path    => '/usr/bin',
        unless  => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"SELECT User FROM mysql.user WHERE User='${mysql_nr_username}' AND Host='localhost';\" | grep -i ${mysql_nr_username}",
      }
      # exec { 'create mysql user newrelic':
      #   command => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"CREATE USER IF NOT EXISTS '${mysql_nr_username}'@'localhost' IDENTIFIED BY '${mysql_nr_user_password.unwrap}'; GRANT REPLICATION CLIENT ON *.* TO '${mysql_nr_username}'@'localhost'; GRANT SELECT ON *.* TO '${mysql_nr_username}'@'localhost';\"",
      #   path    => '/usr/bin',
      # }
      exec { 'install nri-mysql':
        command => 'sudo apt install nri-mysql -y',
        path    => '/bin:/usr/bin',
        unless  => 'dpkg -l | grep nri-mysql',
      }
      file { '/etc/newrelic-infra/integrations.d':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      file { '/etc/newrelic-infra/integrations.d/mysql-config.yml':
        ensure  => 'file',
        content => epp("${module_name}/mysql-config.yml.epp", {
          'username' => "${mysql_nr_username}",      
          'password' => "${mysql_nr_user_password.unwrap}",   
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'], 
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/logging.d':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      file { '/etc/newrelic-infra/logging.d/mysql-log.yml':
        ensure  => 'file',
        content => epp("${module_name}/mysql-log.yml.epp", {
          'log_file' => '/var/log/mysql/error.log', 
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/logging.d'],
        notify  => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/integrations.d/mysql-config.yml.sample':
        ensure => 'absent',
      }
      file { '/etc/newrelic-infra/logging.d/mysql-log.yml.example':
        ensure => 'absent',
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }


}
