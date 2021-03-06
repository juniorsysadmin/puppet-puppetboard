# == Class: puppetboard::apache::conf
#
# Creates an entry in your apache configuration directory
# to run PuppetBoard server-wide (i.e. not in a vhost).
#
# === Parameters
#
# Document parameters here.
#
# [*wsgi_alias*]
#   (string) WSGI script alias source
#   Default: '/puppetboard'
#
# [*threads*]
#   (int) Number of WSGI threads to use.
#   Defaults to 5
#
# [*max_reqs*]
#   (int) Limit on number of requests allowed to daemon process
#   Defaults to 0 (no limit)
#
# [*user*]
#   (string) WSGI daemon process user, and daemon process name
#   Defaults to 'puppetboard' ($::puppetboard::params::user)
#
# [*group*]
#   (int) WSGI daemon process group owner, and daemon process group
#   Defaults to 'puppetboard' ($::puppetboard::params::group)
#
# [*basedir*]
#   (string) Base directory where to build puppetboard vcsrepo and python virtualenv.
#   Defaults to '/srv/puppetboard' ($::puppetboard::params::basedir)
#
# [*enable_ldap_auth]
#   (bool) Whether to enable LDAP auth
#   Defaults to False ($::puppetboard::params::enable_ldap_auth)
#
# [*ldap_bind_dn]
#   (string) LDAP Bind DN
#   No default ($::puppetboard::params::ldap_bind_dn)
#
# [*ldap_bind_password]
#   (string) LDAP password
#   No default ($::puppetboard::params::ldap_bind_password)
#
# [*ldap_url]
#   (string) LDAP connection string
#   No default ($::puppetboard::params::ldap_url)
#
# [*ldap_bind_authoritative]
#   (string) Determines if other authentication providers are used when a user can be mapped to a DN but the server cannot bind with the credentials
#   No default ($::puppetboard::params::ldap_bind_authoritative)
#
# === Notes:
#
# Make sure you have purge_configs set to false in your apache class!
#
# This runs the WSGI application with a WSGIProcessGroup of $user and
# a WSGIApplicationGroup of %{GLOBAL}.
#
class puppetboard::apache::conf (
  $wsgi_alias               = '/puppetboard',
  $threads                  = 5,
  $max_reqs                 = 0,
  $user                     = $::puppetboard::params::user,
  $group                    = $::puppetboard::params::group,
  $basedir                  = $::puppetboard::params::basedir,
  $enable_ldap_auth         = $::puppetboard::params::enable_ldap_auth,
  $ldap_bind_dn             = $::puppetboard::params::ldap_bind_dn,
  $ldap_bind_password       = $::puppetboard::params::ldap_bind_password,
  $ldap_url                 = $::puppetboard::params::ldap_url,
  $ldap_bind_authoritative  = $::puppetboard::params::ldap_bind_authoritative

) inherits ::puppetboard::params {

  $docroot = "${basedir}/puppetboard"

  # Template Uses:
  # - $basedir
  #
  file { "${docroot}/wsgi.py":
    ensure  => present,
    content => template('puppetboard/wsgi.py.erb'),
    owner   => $user,
    group   => $group,
    require => [
      User[$user],
      Vcsrepo[$docroot],
    ],
  }

  # Template Uses:
  # - $user
  # - $group
  # - $threads
  # - $wsgi_alias
  # - $docroot
  #
  file { "${::puppetboard::params::apache_confd}/puppetboard.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    content => template('puppetboard/apache/conf.erb'),
    require => File["${docroot}/wsgi.py"],
    notify  => Service[$::puppetboard::params::apache_service],
  }
}
