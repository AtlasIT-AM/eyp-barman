class barman::config(
                      $barmanhome=$barman::params::barmanhome_default,
                      $barmanlog=$barman::params::barmanlog_default,
                      $barmanconfigdir=$barman::params::barmanconfigdir_default,
                      $compression='gzip',
                    ) inherits barman::params {

  file { $barmanhome:
    ensure => 'directory',
    owner => $barman::params::barmanuser,
    group => $barman::params::barmangroup,
    mode => '0755',
  }

  file { $barmanconfigdir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    require => Package[$barman::params::barman_package],
  }

}
