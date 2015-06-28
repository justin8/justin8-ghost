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
# [*service_type*]
#   Can be either 'systemd' or 'docker'. Locations will remain the same for user data.
#   However, if it is set to 'docker' the host IP will always be 0.0.0.0 due to limitations
#   in docker.
#
# [*version*]
#   The version of ghost to install. Specifying a new version will update
#   installed instances to the new (or old) version. (Optional)
#
# [*host*]
#   Host IP to listen on. (Optional) Defaults to localhost.
#   This is ignored when service_type = docker
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
  $service_type = 'systemd',
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
  validate_re($service_type, '(systemd|docker)')
  validate_re($version, '\d\.\d\.\d')
  validate_re($port, '\d+')
  validate_string(url)

  $service = "ghost_${title}"
  $service_file = "/etc/systemd/system/${service}.service"
  $source = "https://en.ghost.org/archives/ghost-${version}.zip"

  Exec {
    path => $::path
  }

  if $service_type == 'docker' {
    include docker
    $config_port = '2368'
    $config_host = '0.0.0.0'

    ensure_resource('docker::image', 'ghost', { 'image_tag' => $version } )

    file { $home:
      ensure  => directory,
    }

    docker::run { "ghost_${title}":
      image     => "ghost:${version}",
      command   => 'npm start --production',
      ports     => "${port}:${config_port}",
      volumes   => "${home}:/var/lib/ghost",
      require   => Docker::Image['ghost'],
      subscribe => File["ghost_config_${title}"],
    }
  } else {
    $config_port = $port
    $config_host = $host

    ensure_packages(['curl', 'unzip'])

    file { $home:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      recurse => true,
    }

    exec { "ghost_download_${title}":
      cwd     => $ghost::home,
      command => "curl -L ${source} -o ${version}.zip",
      unless  => "test -f ${version}.zip",
      require => File[$home],
      notify  => Exec["ghost_unzip_${title}"],
    }

    exec { "ghost_unzip_${title}":
      cwd     => $home,
      command => "unzip -ou '${ghost::home}/${version}.zip' && rm '${home}/npm_install_complete'",
      unless  => "grep 'version' package.json 2>/dev/null | grep -q '${version}'",
      notify  => [ Exec["ghost_npm_install_${title}"], Exec["ghost_npm_install_${title}"] ],
    }

    exec { "ghost_npm_install_${title}":
      cwd         => $home,
      #command     => "${::nodejs::params::npm_path} install --production",
      command     => "/usr/bin/npm install --production && touch '${home}/npm_install_complete'",
      unless      => "test -f '${home}/npm_install_complete'",
      refreshonly => true,
      notify      => [ Service[$service], Exec["ghost_permissions_${title}"] ],
    }

    # Had to do this due to dependency order. We require the folder, but the permissions need to be done after
    # Otherwise 2 puppet runs would be required to apply cleanly
    exec { "ghost_permissions_${title}":
      path        => '/usr/bin',
      command     => "chown -R ${user}:${group} '${home}'",
      refreshonly => true,
      subscribe   => File["ghost_config_${title}"],
      before      => Service[$service],
    }

    file { $service_file:
      content => template('ghost/systemd.service.erb'),
      notify  => Exec['systemd-daemon-reload'],
    }

    service { $service:
      ensure    => running,
      enable    => true,
      subscribe => File["ghost_config_${title}", $service_file],
    }
  }

  file { "ghost_config_${title}":
    owner   => $user,
    group   => $group,
    path    => "${home}/config.js",
    content => template('ghost/config.js.erb'),
    require => File[$home],
  }

}
