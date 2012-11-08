# Manage gem repo sources
define rvm::define::gem_source(
  $ensure = 'present',
  $ruby_version,
) {  
  ## Set sensible defaults for Exec resource
  Exec {
    path    => '/usr/local/rvm/bin:/bin:/sbin:/usr/bin:/usr/sbin',
  }
  
  # Local Parameters
  $rvm_path = '/usr/local/rvm'
  $rvm_ruby = "${rvm_path}/rubies"
  $rvm_depency = "install-ruby-${ruby_version}"      
  
  # Setup proper install/uninstall commands based on gem version.
  $gem_source = {
    'install'   => "rvm ${ruby_version}; gem sources -a ${name}",
    'uninstall' => "rvm ${ruby_version}; gem sources -r ${name}",
    'lookup'    => "rvm ${ruby_version}; gem sources -l | grep ${name}",
  }

  
  ## Begin Logic
  if $ensure == 'present' {
    exec { "rvm-gem_source-install-${name}-${ruby_version}":
      command => $gem_source['install'],
      unless  => $gem_source['lookup'],
      require => [Class['rvm'], Exec[$rvm_depency]],
    }
  } elsif $ensure == 'absent' {
    exec { "rvm-gem_source-uninstall-${name}-${ruby_version}":
      command => $gem_source['uninstall'],
      onlyif  => $gem_source['lookup'],
      require => [Class['rvm'], Exec[$rvm_depency]],
    }    
  }
}
