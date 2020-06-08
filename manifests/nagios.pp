class barman::nagios(
                      $basedir              = '/usr/local/bin',
                      $add_nrpe_sudos       = true,
                      $install_snmpd_checks = true,
                    ) inherits barman::params {
  include ::barman

  file { "${basedir}/check_barman_servers":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => file("${module_name}/nagios/check_barman_servers.sh"),
  }

  file { "${basedir}/check_barman_backups":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => file("${module_name}/nagios/check_barman_backups.sh"),
  }

  file { "${basedir}/report_barman_servers":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => file("${module_name}/nagios/report_barman_servers.sh"),
  }

  # compatibility
  file { "${basedir}/check_barman_backups_failed":
    ensure => 'link',
    target => "${basedir}/check_barman_backups",
  }

  if($add_nrpe_sudos)
  {
    nrpe::sudo { 'sudo NRPE check_barman_backups':
      command => "${basedir}/check_barman_backups",
    }

    nrpe::sudo { 'sudo NRPE check_barman_servers':
      command => "${basedir}/check_barman_servers",
    }

    # compatibility
    nrpe::sudo { 'sudo NRPE check_barman_backups_failed':
      command => "${basedir}/check_barman_backups_failed",
    }
  }

  if($install_snmpd_checks)
  {
    if(defined(Class['snmpd']))
    {
      snmpd::extend { 'barman_servers':
        script      => "/bin/bash ${puppet::agent::nagios_check_basedir}/report_barman_servers",
        description => 'barman servers',
      }

      snmpd::extend { 'barman_backups':
        script      => "/bin/bash ${puppet::agent::nagios_check_basedir}/check_barman_backups",
        description => 'barman backups',
      }
    }
  }
}
