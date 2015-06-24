# == Class: ghost
#
# Module to install, manage and configure ghost blogs.
#
# === Parameters
#
# [*user*]
#   The user who will own ghost package files and the default user for
#   individual instances
#
# [*group*]
#   The group which will own ghost package files and the default group for
#   individual instances
#
# [*home*]
#   The home folder in which ghost package files will be downloaded and where
#   individual instances will be installed by default
#
# [*include_nodejs*]
#   Whether or not to include the nodejs module. If you require custom settings
#   it would be best to configure them and make this class require it.
#
class ghost(
  $user = $ghost::params::user,
  $group = $ghost::params::group,
  $home = $ghost::params::home,
  $include_nodejs = $ghost::params::include_nodejs,
) inherits ghost::params {

  validate_string($user)
  validate_string($group)
  validate_absolute_path($home)
  validate_bool($include_nodejs)

  contain ghost::install
  include systemd

  Class['ghost'] -> Ghost::Instance <||>
}
