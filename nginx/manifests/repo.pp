class nginx::repo {
   package { 'git':
     ensure => present,
     refreshonly => true,
   }
   vcsrepo { '/home/blake/code/saturn':
     ensure   => latest,
     provider => git,
     source   => 'https://github.com/prvnmali2017/saturn.git',
     revision => 'master',
   }
}
