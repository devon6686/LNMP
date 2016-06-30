include:
  - lnmp.mysql.os_user
  - lnmp.mysql.pkg

mysql-package:
  file.managed:
    - name: /tmp/mysql-5.6.31.tar.gz
    - source: salt://lnmp/mysql/template/mysql-5.6.31.tar.gz
    - unless: test -e /tmp/mysql-5.6.31.tar.gz

mysql_install:
  cmd.script:
    - source: salt://lnmp/mysql/template/mysql-install.sh.template
    - template: jinja
    - mode: 0755
    - require: 
      - file: mysql-package
    - unless: test -e /usr/local/mysql
    - defaults:
      USER: {{ salt['pillar.get']('basic:mysql:user') }}
      GROUP: {{ salt['pillar.get']('basic:mysql:group') }}
      BASEPATH: {{ salt['pillar.get']('basic:mysql:basepath') }}
      BASEDIR: {{ salt['pillar.get']('basic:mysql:basedir') }}
      DATADIR: {{ salt['pillar.get']('basic:mysql:datadir') }}

/etc/my.cnf:
  file.managed:
    - source: salt://lnmp/mysql/template/my.cnf.template
    - template: jinja
    - user: mysql
    - group: mysql
    - defaults:
      BASEDIR: {{ salt['pillar.get']('basic:mysql:basedir') }}
      DATADIR: {{ salt['pillar.get']('basic:mysql:datadir') }}

/etc/init.d/mysqld:
  file.managed:
    - source: salt://lnmp/mysql/template/mysqld.template
    - template: jinja
    - mode: 0755
    - defaults:
      BASEDIR: {{ salt['pillar.get']('basic:mysql:basedir') }}
      DATADIR: {{ salt['pillar.get']('basic:mysql:datadir') }}
      
/etc/profile.d/mysql.sh:
  file.managed:
    - source: salt://lnmp/mysql/template/mysql.sh.template
    - template: jinja
    - mode: 0755
    - defaults:
      BASEDIR: {{ salt['pillar.get']('basic:mysql:basedir') }}

mysql_path:
  cmd.run:
    - name: source /etc/profile.d/mysql.sh
    - require:
      - file: /etc/profile.d/mysql.sh
       
/etc/ld.so.conf.d/mysql.conf:
  file.managed:
    - source: salt://lnmp/mysql/template/mysql.conf.template
    - template: jinja
    - mode: 0755
    - defaults:
      BASEDIR: {{ salt['pillar.get']('basic:mysql:basedir') }}
      
mysql_lib:
  cmd.run:
    - name: ldconfig -v
    - require:
      - file: /etc/ld.so.conf.d/mysql.conf

mysql_head:
  file.symlink:
    - name: {{ salt['pillar.get']('basic:mysql:basedir') }}/include
    - target: /usr/include/mysql
    - mode: 0755  
    - force: True
    - unless: test -L /usr/include/mysql
    
  
mysqld:
  service.running:
    - enable: True
    - require:
      - file: /etc/my.cnf
      - file: /etc/init.d/mysqld
      - cmd: mysql_install


