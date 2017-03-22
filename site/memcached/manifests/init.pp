
class { 'memcached':
    package { 'memcached':
        ensure => latest,
    }
    
    file { '/etc/sysconfig/memcached':
        ensure => file,
        owner  => "root",
        group  => "root",
        mode   => "0644",
        source => "puppet:///modules/memcached/memcached",
        require => Package["memcached"],
    }
    
    service { 'memcached':
        ensure => running,
        enable => True,
        subscribe => File["/etc/sysconfig/memcached"],
    }
}
