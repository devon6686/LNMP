dev-tools:
  cmd.run:
    - name: yum -y groupinstall 'Development Tools'

nginx-env:
  pkg.installed:
    - pkgs:
      - pcre-devel
      - openssl-devel
      - gd-devel
      - zlib-devel 

nginx-user:
  user.present:
    - name: nginx
    - system: True
    - shell: /bin/shell
    - createhome: False
    - empty_password: True 
    - unless: id nginx

nginx-1.8.1:
  file.managed:
    - source: salt://lnmp/nginx/template/nginx-1.8.1.tar.gz
    - name: /tmp/nginx-1.8.1.tar.gz
    - unless: test -e /tmp/nginx-1.8.1.tar.gz
  
nginx-install:
  cmd.script:
    - source: salt://lnmp/nginx/template/nginx-install.sh.template
    - template: jinja
    - mode: 755
    - require:
      - file: nginx-1.8.1
      - user: nginx-user
    - unless: nginx -v
    - defaults:
      USER: {{ salt['pillar.get']('basic:nginx:user') }}
      GROUP: {{ salt['pillar.get']('basic:nginx:group') }}
      PREFIX: {{ salt['pillar.get']('basic:nginx:prefix') }}
      CONF_FILE: {{ salt['pillar.get']('basic:nginx:conf_file') }}
      PID_FILE: {{ salt['pillar.get']('basic:nginx:pid_file') }}
      SBIN_FILE: {{ salt['pillar.get']('basic:nginx:sbin_file') }}
      LOG_PATH: {{ salt['pillar.get']('basic:nginx:log_path') }}
      LOCK_FILE: {{ salt['pillar.get']('basic:nginx:lock_file') }}
      TEMP_PATH: {{ salt['pillar.get']('basic:nginx:temp_path') }}
      WEB_ROOT: {{ salt['pillar.get']('basic:nginx:web_root') }}
      PARAMETERS: {{ salt['pillar.get']('basic:nginx:parameters') }}
    - env:
      - BATCH: 'yes'
    
nginx.conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://lnmp/nginx/template/nginx.conf.template
    - template: jinja
    - mode: 0644
    - defaults:
      HOSTNAME: {{ grains['host'] }}
      USER: {{ salt['pillar.get']('basic:nginx:user') }}
      PREFIX: {{ salt['pillar.get']('basic:nginx:prefix') }}
      PID_FILE: {{ salt['pillar.get']('basic:nginx:pid_file') }}
      LOG_PATH: {{ salt['pillar.get']('basic:nginx:log_path') }}
      WEB_ROOT: {{ salt['pillar.get']('basic:nginx:web_root') }}
      
nginx.service:
  file.managed:
    - name: /usr/lib/systemd/system/nginx.service
    - source: salt://lnmp/nginx/template/nginx.service.template
    - template: jinja
    - mode: 0644
    - defaults:
      PID_FILE: {{ salt['pillar.get']('basic:nginx:pid_file') }}

nginx-service:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - cmd: nginx-install
      - file: nginx.service
    - watch:
      - file: nginx.conf
