$package_name = 'httpd'

if $facts['os']['family'] == 'RedHat' {
  $apache = 'httpd'
} else {
  $apache = 'apache2'
}

case $facts['os']['name'] {
  'RedHat', 'CentOS': { $ssh_service = 'sshd' }
  'Debian', 'Ubuntu': { $ssh_service = 'ssh' }
  default: { fail('Unsupported operating system') }
}

File {
  owner => 'root',
  group => 'root',
  mode  => '0644',
}

class ssh_server {
  package { 'openssh-server':
    ensure => installed,
  }

  service { 'sshd':
    ensure => running,
    enable => true,
  }
}

define virtual_host($port, $document_root) {
  file { "/etc/apache2/sites-available/${name}.conf":
    ensure  => file,
    content => template('apache/vhost.erb'),
  }
}

node 'webserver.example.com' {
  include ssh_server
}
