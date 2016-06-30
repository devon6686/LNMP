install-nginx:
  salt.state:
    - tgt: 'nginx*'
    - sls:
      - lnmp.nginx
