# == Class: ghost::params
#
# Default parameter values for the ghost module
#
class ghost::params {
  $user = 'ghost'
  $group = 'ghost'
  $home  = '/srv/ghost'
  $include_nodejs = false
  $version = '0.7.1'
}
