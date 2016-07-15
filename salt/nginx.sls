install-nginx:
  salt.state:
    - tgt: '*'
    - sls:
      - lnmp.nginx
