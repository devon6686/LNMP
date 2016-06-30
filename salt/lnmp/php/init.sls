php-env:
  pkg.installed:
    - pkgs:
      - openssl-devel
      - zlib-devel
      - libxml2-devel
      - bzip2-devel
      - libcurl-devel
      - libmcrypt-devel

php-user:
  user.present:
    - name: www
    - system: True
    - createhome: False
    - shell: /bin/shell
    - empty_password: True
    - unless: id www

php-package:
  file.managed:
    - name: /tmp/php-5.6.22.tar.bz2
    - source: salt://lnmp/php/template/php-5.6.22.tar.bz2
    - unless: test -e /tmp/php-5.6.22.tar.bz2

php-install:
  cmd.script:
    - source: salt://lnmp/php/template/php-install.sh.template
    - template: jinja
    - defaults:
      PREFIX: {{ salt['pillar.get']('basic:php:prefix') }}
      USER: {{ salt['pillar.get']('basic:php:user') }}
      GROUP: {{ salt['pillar.get']('basic:php:group') }}
      PARAMETER: {{ salt['pillar.get']('basic:php:parameter') }}
    - require:
      - pkg: php-env
      - user: php-user
      - file: php-package
    - unless: test -e /usr/local/php
    - env:
      - BATCH: 'yes'

fpm-file:
  file.managed:
    - name: /etc/init.d/php-fpm
    - source: salt://lnmp/php/template/php-fpm
    - mode: 0755

php-fpm.conf:
  file.managed:
    - name: /usr/local/php/etc/php-fpm.conf
    - source: salt://lnmp/php/template/php-fpm.conf

php.ini:
  file.managed:
    - name: /etc/php.ini
    - source: salt://lnmp/php/template/php.ini.template
    - template: jinja
    - defaults:
      MYSQL_HOST: {{ salt['pillar.get']('basic:php:mysql_host') }}
      MYSQL_SOCKET: {{ salt['pillar.get']('basic:php:mysql_socket') }}

php.sh:
  file.managed:
    - name: /etc/profile.d/php.sh
    - source: salt://lnmp/php/template/php.sh.template
    - template: jinja
    - mode: 0755
    - defaults:
      PREFIX: {{ salt['pillar.get']('basic:php:prefix') }}

php-path:
  cmd.run:
    - name: source /etc/profile.d/php.sh
    - require: 
      - file: php.sh
      
php-fpm:
  service.running:
    - enable: True
    - require:
      - cmd: php-install
      - file: php.ini
      - file: php-fpm.conf
    - watch:
      - file: fpm-file 

nginx.conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://lnmp/php/template/nginx.conf.template
    - template: jinja
    - defaults:
      HOSTNAME: {{ grains['host'] }}
      USER: {{ salt['pillar.get']('basic:nginx:user') }}
      PREFIX: {{ salt['pillar.get']('basic:nginx:prefix') }}
      PID_FILE: {{ salt['pillar.get']('basic:nginx:pid_file') }}
      LOG_PATH: {{ salt['pillar.get']('basic:nginx:log_path') }}
      WEB_ROOT: {{ salt['pillar.get']('basic:nginx:web_root') }}

fastcgi.conf:
  file.managed:
    - name: /etc/nginx/fastcgi.conf 
    - source: salt://lnmp/php/template/fastcgi.conf
    - mode: 0644

nginx.service:
  cmd.run:
    - name: systemctl reload nginx
    - require:
      - file: nginx.conf
      - file: fastcgi.conf
      - service: php-fpm 
      
