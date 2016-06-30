install-mysql:
  salt.state:
    - tgt: 'nginx*'
    - sls:
      - lnmp.mysql
    - require:
      - salt: install-nginx
