#LNMP
salt-install LNMP(nginx1.8.1+mysql5.6.31+php5.6.22)

#Install
salt-run state.orch lnmp-setup -l debug > /root/log

which contains commands in the following order:

1.  salt \* state.sls lnmp.nginx [ -l debug > /root/log ]
2.  salt \* state.sls lnmp.mysql [ -l debug > /root/log ]
3.  salt \* state.sls lnmp.php   [ -l debug > /root/log ]


2016-08-24 issues:
Using unix socket for php-fpm 
