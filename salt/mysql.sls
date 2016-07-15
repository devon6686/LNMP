install-mysql:
  salt.state:
    - tgt: '*'
    - sls:
      - lnmp.mysql
    - require:
      - salt: install-nginx
