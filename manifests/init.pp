# == Class: barman
#
# === barman documentation
#
class barman(
              #install
              $sshkey_type,
              $sshkey_key,
              #config
              $barmanhome=$barman::params::barmanhome_default,
              $barmanlog=$barman::params::barmanlog_default,
              $barmanconfigdir=$barman::params::barmanconfigdir_default,
              $compression='gzip',
              $
              #service
            ) inherits barman::params{

  include ::epel

  class { '::barman::install':
    sshkey_type => $sshkey_type,
    sshkey_key  => $sshkey_key,
  } ->

  class { '::barman::config':
    barmanhome      => $barmanhome,
    barmanlog       => $barmanlog,
    barmanconfigdir => $barmanconfigdir,
    compression     => $compression,
  } ~>

  class { '::barman::service': } ->

  Class['::barman']

}
