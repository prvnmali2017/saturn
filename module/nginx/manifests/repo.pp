class nginx::repo {

   exec { "apt-get update":
     command     => "/usr/bin/apt-get update",
     refreshonly => true,
   }
   
   package { 'git':
     ensure   => installed,
     require  => Exec['apt-get update'],
   }
   vcsrepo { '/etc/puppetlabs/code/exercise-webpage':
     ensure   => latest,
     provider => git,
     source   => 'https://github.com/puppetlabs/exercise-webpage',
     revision => 'master',
   }
}
