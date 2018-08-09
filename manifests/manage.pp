# Define: win_scheduled_task
# Parameters:
# arguments
#
define win_scheduled_task::manage (
  $file_source = '',
  $ensure = 'present',
) {

  if $facts['os']['name'] != 'Windows' {
    fail('importing scheduled tasks only works on windows')
  }

  case $ensure {
    'absent': {
      import_task { $name:
      ensure => $ensure,
    }
  }
    default: {

      File {
        owner => 'Administrators',
        group => 'Users',
      }

      if ! defined(File["${facts['puppet_vardir']}/scheduledtasks"]) {
        file { "${facts['puppet_vardir']}/scheduledtasks":
          ensure => directory,
        }
      }

      file { "${facts['puppet_vardir']}/scheduledtasks/${name}.xml":
        ensure => file,
        source => $file_source,
      }

      import_task { $name:
        ensure    => $ensure,
        task   => "${facts['puppet_vardir']}/scheduledtasks/${name}.xml",
        require   => File["${facts['puppet_vardir']}/scheduledtasks/${name}.xml"],
        subscribe => File["${facts['puppet_vardir']}/scheduledtasks/${name}.xml"],
      }
    }
  }
}
