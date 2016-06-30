add_user:
  user.present:
    - name: mysql
    - shell: /bin/bash
    - createhome: False
    - empty_password: True
    - system: True
    - unless: id mysql

