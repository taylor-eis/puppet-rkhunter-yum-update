class rkhunter_yum_update {
  case $facts['os']['release']['major'] {
    '7': {
      $pkg = 'yum-plugin-post-transaction-actions'
      $file = '/etc/yum/post-actions/rkhunter.action'
    }
    '8','9': {
      $pkg = 'python3-dnf-plugin-post-transaction-actions'
      $file = '/etc/dnf/plugins/post-transaction-actions.d/rkhunter.action'
    }
  }

  $job = '#!/bin/bash

if [[ -f /var/lib/rkhunter/updated.txt ]] ; then
    while read in; do /usr/bin/rkhunter --propupdate "$in" > /dev/null; done < /var/lib/rkhunter/updated.txt
    rm -rf /var/lib/rkhunter/updated.txt
fi'

  package { 'post-transactions':
    ensure => latest,
    name => $pkg,
  }

  file { 'rkhunter.action':
    ensure => file,
    path => $file,
    content => '*:any:echo $name >> /var/lib/rkhunter/updated.txt',
    require => Package['post-transactions'],
  }

  file { '/etc/cron.daily/0rkhunter':
    ensure => file,
    content => $job,
    mode => "0755",
  }
}    
