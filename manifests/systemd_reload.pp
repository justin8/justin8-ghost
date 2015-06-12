# == Class: ghost::systemd_reload
#
# For systems that have systemd. When will this be upstream??
#
class ghost::systemd_reload {
  exec { 'ghost-systemd-reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
