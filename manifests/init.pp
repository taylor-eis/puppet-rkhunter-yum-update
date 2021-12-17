class rkhunter_yum_update {
  case $facts['os']['release']['major'] {
    '7': {
      $pkg = 'yum-plugin-post-transaction-actions'
    }
    '8': {
      $pkg = 'python3-dnf-plugin-post-transaction-actions'
    }
  }

  $job = '#!/bin/bash

if [[ -f /var/lib/rkhunter/updated.txt ]] ; then
    while read in; do /usr/bin/rkhunter --propupdate "$in" > /dev/null; done < /var/lib/rkhunter/updated.txt
    rm -rf /var/lib/rkhunter/updated.txt
fi'

  package { 'post-transactions':
    ensure => latest,
    name => $pkgq,
  }

  file { '/etc/yum/post-actions/rkhunter.action':
    ensure => file,
    content => "*:any:echo $name >> /var/lib/rkhunter/updated.txt",
    require => Package['post-transactions'],
  }

  cron::daily { '0rkhunter':
    command => $job,
    user => root,
  }
}    
