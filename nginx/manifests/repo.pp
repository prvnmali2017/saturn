class nginx::repo {
   vcsrepo { '/home/blake/code/saturn':
     ensure   => latest,
     provider => git,
     source   => 'https://github.com/prvnmali2017/saturn.git',
     revision => 'master',
   }
}
