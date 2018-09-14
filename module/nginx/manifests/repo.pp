class nginx::repo {

   exec { "apt-get update":
     command     => "/usr/bin/apt-get update",
     refreshonly => true,
   }
   
   package { 'git':
     ensure   => installed,
     require  => Exec['apt-get update'],
   }
   vcsrepo { '/home/blake/code/saturn':
     ensure   => latest,
     provider => git,
     source   => 'https://github.com/prvnmali2017/saturn.git',
     revision => 'master',
   }
}
