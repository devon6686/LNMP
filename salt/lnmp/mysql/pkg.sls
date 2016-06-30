mysql-depend:
  pkg.installed:
    - pkgs:
      - MySQL-python
      - net-tools

mariadb-package:
  pkg.removed:
    - pkgs: 
      - mariadb-libs
      - mariadb


