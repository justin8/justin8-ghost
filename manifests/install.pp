# == Class: ghost::install
#
# Module to install requirements for ghost blogs.
# This module should work on all distributions supported on
# puppetlabs/nodejs (except windows)
#
class ghost::install {

  if $ghost::include_nodejs {
    include nodejs
  }

  group { $ghost::group:
    ensure => present,
    system => true,
  }

  user { $ghost::user:
    ensure     => present,
    system     => true,
    home       => $ghost::home,
    gid        => $ghost::group,
    require    => Group[$ghost::group],
  }->

  file { "/srv/ghost":
    owner => $ghost::user,
    group => $ghost::group,
    mode  => "0755",
  }
}
