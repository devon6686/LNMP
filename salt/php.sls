install-php:
  salt.state:
    - tgt: '*'
    - sls:
      - lnmp.php
    - require:
      - salt: install-mysql
