class nginx {
     require nginx::repo
     File {
         owner   => 'root',
         group   => 'root',
         mode    => '0644',
      }
      package { 'nginx':
         ensure  =>  present, 
      }
      file { '/var/www': 
         ensure  =>  directory, 
      }
      file { '/var/www/index.html':
         ensure  =>  file,
         source  => 'file:/etc/puppetlabs/code/exercise-webpage/index.html',
      }
      file { '/etc/nginx/nginx.conf':
         ensure  =>  file,
         source  => 'puppet:///modules/nginx/nginx.conf',
         require =>  Package['nginx'],
         notify  =>  Service['nginx'],
       }
      file { '/etc/nginx/sites-enabled/default':
         ensure  =>  file,
         source  => 'puppet:///modules/nginx/default.conf',
         require =>  Package['nginx'],
         notify  =>  Service['nginx'],
      }
      service { 'nginx':
         ensure  =>  running,
         enable  =>  true,
      } 
}
