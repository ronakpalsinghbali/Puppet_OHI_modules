node default {
  notify { 'This is the OHI environment': }
}

node 'puppetagent-debian.ceq.com' {
  notify { 'This is the OHI environment - Debian': }

  # class { 'newrelic_infra::agent':
  #   display_name => 'Puppet-agent-Debian',
  #   ensure       => 'present',
  #   license_key  => '',
  # }

  # class {'eq_ohi_jmx::install':
  #   jmx_nr_user_password  => Sensitive(""),
  #   jmx_nr_username         => "",
  #   tomcat_domain           => "Catalina", 
  #   jvm_domain              => "java.lang",
  #   jmx_port                => "",
  # }
  # class {'eq_ohi_jmx::remove': }

  # class {'eq_ohi_mysql::install': 
  #   mysql_nr_username        => "",
  #   mysql_nr_user_password  => Sensitive(""),
  #   mysql_root_password      => Sensitive(''),
  # }
  # class { 'eq_ohi_mysql::remove':
  #   mysql_nr_username => '',
  #   mysql_root_password => Sensitive('$$12_'),
  # }
}

node 'puppetagent-rhel.ceq.com' {
  notify { 'This is the OHI environment - RHEL': }

  # class { 'newrelic_infra::agent':
  #   display_name => 'Puppet-agent-RHEL',
  #   ensure       => 'present',
  #   license_key  => '',
  # }

  # class {'eq_ohi_mysql::install': 
  #   mysql_nr_username         => "",
  #   mysql_nr_user_password    => Sensitive(""),
  #   mysql_root_password       => Sensitive(''),
  # }
  # class { 'eq_ohi_mysql::remove':
  #   mysql_nr_username   => '',
  #   mysql_root_password => Sensitive(''),
  # }
}

node 'puppetagent-win.ceq.com' {
  notify { 'This is the OHI environment - Windows': }

  # class { 'newrelic_infra::agent':
  #   display_name => 'Puppet-agent-Windows',
  #   ensure       => 'present',
  #   license_key  => '',
  # }

  # class {'eq_ohi_jmx::install': 
  #   jmx_nr_user_password  => Sensitive(""),
  #   jmx_nr_username         => "",
  #   tomcat_domain           => "Catalina", 
  #   jvm_domain              => "java.lang",
  #   jmx_port                => "",
  # }
  # class {'eq_ohi_jmx::remove': }

  # include eq_profile_mysql
  # class {'eq_ohi_mysql::install': 
  #   mysql_nr_username        => "",
  #   mysql_nr_user_password  => Sensitive(""),
  #   mysql_root_password     => Sensitive(''),
  # }
  # class { 'eq_ohi_mysql::remove':
  #   mysql_nr_username   => '',
  #   mysql_root_password => Sensitive(''),
  # }
}

node 'puppetagent-rhel-2.ceq.com' {
  notify { 'This is the OHI environment - RHEL 2': }

  # class { 'newrelic_infra::agent':
  #   display_name => 'Puppet-agent-RHEL-2',
  #   ensure       => 'present',
  #   license_key  => '',
  # }

  # class {'eq_ohi_jmx::install': 
  #   jmx_nr_user_password  => Sensitive(""),
  #   jmx_nr_username         => "",
  #   tomcat_domain           => "Catalina", 
  #   jvm_domain              => "java.lang",
  #   jmx_port                => "",
  # }
  # class {'eq_ohi_jmx::remove': }

  # class {'eq_ohi_oracledb::install': 
  #   oracledb_service_name        => '',
  #   oracledb_nr_username         => '',
  #   oracledb_nr_user_password    => Sensitive(""),
  #   oracledb_root_password       => Sensitive(''),
  #   oracle_home                  => '',
  #   is_sys_dba                   => 'false',
  #   is_sys_oper                  => 'false',
  #   port                         => '',
  # }
  # class { 'eq_ohi_oracledb::remove': }
}
