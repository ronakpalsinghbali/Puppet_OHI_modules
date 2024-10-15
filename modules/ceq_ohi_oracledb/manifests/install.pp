class eq_ohi_oracledb::install (
  String $oracledb_service_name = '',
  String $oracledb_nr_username = '',
  Sensitive[String] $oracledb_nr_user_password = Sensitive(''),
  Sensitive[String] $oracledb_root_password = Sensitive(''),
  String $oracle_home = '',
  String $is_sys_dba = '',
  String $is_sys_oper = '',
  String $port = '',
){
  case $facts['os']['family'] {
    'RedHat': {
      exec { "create-oracle-user-${oracledb_nr_username}":
        command => "sudo -u oracle sh -c '${oracle_home}/bin/sqlplus sys/${oracledb_root_password.unwrap}@${oracledb_service_name} as sysdba <<EOSQL
                    WHENEVER SQLERROR EXIT SQL.SQLCODE;
                    ALTER SESSION SET \"_Oracle_SCRIPT\"=true;
                    CREATE USER ${oracledb_nr_username} IDENTIFIED BY '${oracledb_nr_user_password.unwrap}';
                    GRANT CONNECT TO ${oracledb_nr_username};
                    GRANT SELECT ON cdb_data_files TO ${oracledb_nr_username};
                    GRANT SELECT ON cdb_pdbs TO ${oracledb_nr_username};
                    GRANT SELECT ON cdb_users TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$sysmetric TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$pgastat TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$instance TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$filestat TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$parameter TO ${oracledb_nr_username};
                    GRANT SELECT ON sys.dba_data_files TO ${oracledb_nr_username};
                    GRANT SELECT ON DBA_TABLESPACES TO ${oracledb_nr_username};
                    GRANT SELECT ON DBA_TABLESPACE_USAGE_METRICS TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$session TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$sesstat TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$statname TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$rowcache TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$sga TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$sysstat TO ${oracledb_nr_username};
                    GRANT SELECT ON v_\\\$database TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$librarycache TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$sqlarea TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$system_event TO ${oracledb_nr_username};
                    GRANT SELECT ON dba_tablespaces TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$session_wait TO ${oracledb_nr_username};
                    GRANT SELECT ON gv_\\\$rollstat TO ${oracledb_nr_username};
                    GRANT SELECT ON v_\\\$instance TO ${oracledb_nr_username};
                    EOSQL'",
        path    => '/bin:/usr/bin',
        unless  => "sudo -u oracle sh -c \"${oracle_home}/bin/sqlplus -s sys/${oracledb_root_password.unwrap}@${oracledb_service_name} as sysdba <<EOSQL 
                    SELECT username FROM dba_users WHERE username = UPPER('${oracledb_nr_username}');
                    EOSQL\" | grep -qi '${oracledb_nr_username}'"
      }
      exec { 'install nri-oracledb':
        command => 'sudo yum install nri-oracledb -y',
        path    => '/bin:/usr/bin',
        unless  => 'rpm -q nri-oracledb',
      }
      file { '/etc/newrelic-infra/integrations.d':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      file { '/etc/newrelic-infra/integrations.d/oracledb-config.yml':
        ensure  => 'file',
        content => epp("${module_name}/oracledb-config.yml.epp", {
          'username'      => "${oracledb_nr_username}",
          'password'      => "${oracledb_nr_user_password.unwrap}",
          'service_name'  => "${oracledb_service_name}",
          'oracle_home'   => "${oracle_home}",
          'is_sys_dba'    => "${is_sys_dba}",
          'is_sys_oper'   => "${is_sys_oper}",
          'port'          => "${port}"
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/newrelic-infra/integrations.d'],
        notify  => Service['newrelic-infra'],
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }
}
