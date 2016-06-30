install-php:
  salt.state:
    - tgt: 'nginx*'
    - sls:
      - lnmp.php
    - require:
      - salt: install-mysql
