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
      # The following uses microsoft Security Identifiers vs Group names for language support.
      # Such as German windows versions.
      # https://docs.microsoft.com/en-us/windows/security/identity-protection/access-control/security-identifiers
      File {
        owner => 'S-1-5-32-544', # Maps to Administrators
        group => 'S-1-5-32-545', # Maps to Users
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
        task      => "${facts['puppet_vardir']}/scheduledtasks/${name}.xml",
        require   => File["${facts['puppet_vardir']}/scheduledtasks/${name}.xml"],
        subscribe => File["${facts['puppet_vardir']}/scheduledtasks/${name}.xml"],
      }
    }
  }
}
