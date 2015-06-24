# == Define: ghost::instance
#
# A define which manages a ghost instance
#
# == Parameters
#
# [*url*]
#   The URL where this instance will be hosted. e.g. 'https://blog.example.com'. (Required)
#
# [*user*]
#   The user which this instance will run as and which will own all files
#   (Optional)
#
# [*group*]
#   The group which this instance will run as and which will own all files
#   (Optional)
#
# [*home*]
#   The home in which all files will reside. (Optional)
#
# [*version*]
#   The version of ghost to install. Specifying a new version will update
#   installed instances to the new (or old) version. (Optional)
#
# [*host*]
#   Host IP to listen on. (Optional) Defaults to localhost.
#
# [*port*]
#   Default port to listen on. (Optional) Defaults to 2368.
#
# [*transport*]
#   Mail transport option. (Optional) See http://docs.ghost.org/mail/
#
# [*from*]
#   Mail from option. (Optional) See http://docs.ghost.org/mail/
#
# [*mail_options*]
#   Mail misc options. Accepts a hash of options. (Optional) See http://docs.ghost.org/mail/
#
define ghost::instance(
  $url,
  $user         = $ghost::user,
  $group        = $ghost::group,
  $home         = "${ghost::home}/${title}",
  $version      = '0.6.4',
  $host         = '127.0.0.1',
  $port         = '2368',
  $transport    = '',
  $from         = '',
  $mail_options = {},
) {
  validate_string($title)
  validate_string($user)
  validate_string($group)
  validate_absolute_path($home)
  validate_re($version, '\d\.\d\.\d')
  validate_re($port, '\d+')
  validate_string(url)

  $service = "ghost_${title}"
  $service_file = "/etc/systemd/system/${service}.service"
  $source = "https://en.ghost.org/archives/ghost-${version}.zip"

  ensure_packages(['curl', 'unzip'])

  file { $home:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }->

  exec { "ghost_download_${title}":
    cwd     => $ghost::home,
    path    => '/usr/bin',
    command => "curl -L ${source} -o ${version}.zip",
    unless  => "test -f ${version}.zip",
  }->

  exec { "ghost_unzip_${title}":
    cwd     => $home,
    path    => '/usr/bin',
    command => "unzip -ou '${ghost::home}/${version}.zip'",
    unless  => "grep 'version' package.json 2>/dev/null | grep -q '${version}'",
  }~>

  exec { "ghost_npm_install_${title}":
    cwd         => $home,
    command     => "${::nodejs::params::npm_path} install --production",
    refreshonly => true,
    notify      => Service[$service],
  }~>

  # Had to do this due to dependency order. We require the folder, but the permissions need to be done after
  # Otherwise 2 puppet runs would be required to apply cleanly
  exec { "ghost_permissions_${title}":
    path        => '/usr/bin',
    command     => "chown -R ${user}:${group} '${home}'",
    refreshonly => true,
  }~>

  file { "ghost_config_${title}":
    owner   => $user,
    group   => $group,
    path    => "${home}/config.js",
    content => template('ghost/config.js.erb'),
    require => File[$home],
    notify  => Service[$service],
  }

  file { $service_file:
    content => template('ghost/systemd.service.erb'),
    notify  => Exec['systemd-daemon-reload'],
  }

  service { $service:
    ensure  => running,
    enable  => true,
    require => File[$service_file],
  }
}
