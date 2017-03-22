class nginx {
  case $facts['os']['family'] {
    'redhat','debian' : {
      $package   = 'nginx'
      $owner = 'root'
      $group = 'root'
      $docroot   = '/var/www'
      $confdir = '/etc/nginx'
      $logdir    = '/var/log/nginx'
    }
    'windows' : {
      $package   = 'nginx'
      $owner = 'root'
      $group = 'root'
      $docroot   = '/var/www'
      $confdir = '/etc/nginx'
      $logdir    = '/var/log/nginx'
    }
    default : {
      fail("Module ${module_name} is not supported on $facts['os']['family']")
    }
  }
  
  $user = $facts['os']['family'] ? {
    'redhat'  => 'nginx',
    'debian'  => 'www-data',
    'windows' => 'nobody',
  }
    
  File {
    owner  => $owner,
    group  => $group,
    mode   => '0664',
  }
  
  package { $package:
    ensure => present,
    alias  => 'nginx'
  }
  file { [ $docroot, "${confdir}/conf.d" ] :
    ensure => directory,
  }
  file { "${$docroot}/index.html":
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
  }
  file { "${confdir}/nginx.conf":
    ensure  => file,
    content => epp('nginx/nginx.conf.epp', { user => $user, confdir => $confdir, $logdir => logdir }),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
  file { "${configDir}/conf.d/default.conf":
    ensure  => file,
    content => epp('nginx/default.conf.epp' { docroot => $docroot }),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
  service { 'nginx':
    ensure => running,
    enable => true,
  }
}
