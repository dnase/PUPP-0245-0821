class nginx (
  $root = undef,
) {

case $facts['os']['family'] {
  'debian': {
    $nginx_package_name = 'nginx'
    $nginx_owner = 'root'
    $nginx_group = 'root'
    $default_docroot = '/var/www'
    $nginx_conf_root_dir = '/etc/nginx'
    $nginx_conf_incl_dir = '/etc/nginx/conf.d'
    $nginx_log_dir = '/var/log/nginx'
    $nginx_service = 'nginx'
    $nginx_service_account = 'www-data'
  }
  'redhat': {
    $nginx_package_name = 'nginx'
    $nginx_owner = 'root'
    $nginx_group = 'root'
    $default_docroot = '/var/www/'
    $nginx_conf_root_dir = '/etc/nginx'
    $nginx_conf_incl_dir = '/etc/nginx/conf.d'
    $nginx_log_dir = '/var/log/nginx/'
    $nginx_service = 'nginx'
    $nginx_service_account = 'nginx'
  }
  'windows': {
    $nginx_package_name = 'nginx-service'
    $nginx_owner = 'Administrator'
    $nginx_group = 'Administrators'
    $default_docroot = 'C:/ProgramData/nginx/html'
    $nginx_conf_root_dir = 'C:/ProgramData/nginx'
    $nginx_conf_incl_dir = 'C:/ProgramData/nginx/conf.d'
    $nginx_log_dir = 'C:/ProgramData/nginx/logs'
    $nginx_service = 'nginx'
    $nginx_service_account = 'nobody'
  }
  default: {
    fail("Unsupported OS Family ${facts['os']['family']} ")
  }
}

  $nginx_www_dir = $root ? {
    undef => $default_docroot,
    default => $root,
  }

#  
#  $nginx_service_account = $facts['os']['name'] ? {
#    'ubuntu' => 'nginx',
#    'redhat' => 'nginx',
#    'windows' => 'noboxy',
#    default  => 'nginx',
#  }


  $nginx_index_file = 'index.html'
  $nginx_conf_file = 'nginx.conf'
  $nginx_default_file = 'default.conf'

  File {
    owner => 'root',
    group => 'root',
    mode => '0664'
  }


  package { "${nginx_package_name}":
    ensure => latest,
  }
  file { [ "${nginx_www_dir}", "${nginx_conf_root_dir}", "${nginx_conf_incl_dir}" ]:
    ensure => directory,
  }
  file { "${nginx_www_dir}/${nginx_index_file}":
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
    #content =>  epp('nginx/index.html'),
  }
  file { "${nginx_conf_root_dir}/${nginx_conf_file}":
    ensure  => file,
    #source  => 'puppet:///modules/nginx/nginx.conf',
    content =>  epp('nginx/nginx.conf.epp',
    {
    nginx_package_name => $nginx_package_name,
    nginx_owner => $nginx_owner,
    nginx_group => $nginx_group,
    nginx_www_dir => $nginx_www_dir,
    nginx_conf_root_dir => $nginx_conf_root_dir,
    nginx_conf_incl_dir => $nginx_conf_incl_dir,
    nginx_log_dir => $nginx_log_dir,
    nginx_service => $nginx_service,
    nginx_service_account => $nginx_service_account
    }),
    require => Package["${nginx_service}"],
    notify  => Service["${nginx_service}"],
  }

  file { "${nginx_conf_incl_dir}/${nginx_default_file}":
    ensure  => file,
    #source  => 'puppet:///modules/nginx/default.conf',
    content =>  epp('nginx/default.conf.epp',
    {
    nginx_package_name => $nginx_package_name,
    nginx_owner => $nginx_owner,
    nginx_group => $nginx_group,
    nginx_www_dir => $nginx_www_dir,
    nginx_conf_root_dir => $nginx_conf_root_dir,
    nginx_conf_incl_dir => $nginx_conf_incl_dir,
    nginx_log_dir => $nginx_log_dir,
    nginx_service => $nginx_service,
    nginx_service_account => $nginx_service_account
    }),
    require => Package["${nginx_service}"],
    notify  => Service["${nginx_service}"],
  }
  service { "${nginx_service}":
    ensure => running,
    enable => true,
  }
}
