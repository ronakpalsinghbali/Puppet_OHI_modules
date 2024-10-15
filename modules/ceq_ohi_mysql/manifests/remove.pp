class eq_ohi_mysql::remove (
  String $mysql_nr_username = '',
  Sensitive[String] $mysql_root_password = Sensitive(''),
) {

  case $facts['os']['family'] {
    'windows': {
      # Windows-specific removal
      exec { 'delete mysql user newrelic':
        command => "mysql.exe -u root -p\"${mysql_root_password.unwrap}\" -e \"DROP USER IF EXISTS '${mysql_nr_username}'@'localhost';\"",
        path    => 'C:/Program Files/MySQL/MySQL Server 8.0/bin',
      }
      exec { 'uninstall nri-mysql':
        command => 'powershell.exe -Command "Get-WmiObject -Query \'SELECT * FROM Win32_Product WHERE Name = \"New Relic Infrastructure Integration, nri-mysql\"\' | ForEach-Object { $_.Uninstall() }"',
        path    => 'C:/Windows/System32/WindowsPowerShell/v1.0',
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/integrations.d/mysql-config.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { 'C:/Program Files/New Relic/newrelic-infra/logging.d/mysql-log.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
    }
    'RedHat': {
      # RedHat-specific removal
      exec { 'delete mysql user newrelic':
        command => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"DROP USER IF EXISTS '${mysql_nr_username}'@'localhost';\"",
        path    => '/usr/bin',
        unless  => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"SELECT COUNT(*) FROM mysql.user WHERE User='${mysql_nr_username}' AND Host='localhost';\" | grep 0",
      }
      exec { 'remove nri-mysql on RHEL':
        command => 'sudo yum remove -y nri-mysql',
        path    => '/bin:/usr/bin',
        onlyif  => 'rpm -q nri-mysql',
      }
      file { '/etc/newrelic-infra/integrations.d/mysql-config.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/logging.d/mysql-log.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
    }
    'Debian': {
      exec { 'delete mysql user newrelic':
        command => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"DROP USER IF EXISTS '${mysql_nr_username}'@'localhost';\"",
        path    => '/usr/bin',
        unless  => "mysql -u root -p'${mysql_root_password.unwrap}' -e \"SELECT COUNT(*) FROM mysql.user WHERE User='${mysql_nr_username}' AND Host='localhost';\" | grep 0",
      }
      exec { 'remove nri-mysql':
        command => 'sudo apt remove --purge nri-mysql -y',
        path    => '/bin:/usr/bin',
        onlyif  => 'dpkg -l | grep nri-mysql',
      }
      file { '/etc/newrelic-infra/integrations.d/mysql-config.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
      file { '/etc/newrelic-infra/logging.d/mysql-log.yml':
        ensure => 'absent',
        notify => Service['newrelic-infra'],
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }
}
