# Ubuntu LAMP docker
# Supervisor, Cron, SSH, Apache2, PHP7.0, MariaDB, FTP, Redis

All services are run under supervisor. FTP, Cron and Redis are stopped by default.

SSH    - root/root

MySql - root/root

FTP - root/root


Exposed ports: 21, 22, 80, 3306

Build docker image: docker build -t marvicz/ubuntu-lamp .

Example to start: docker run -d --name test -p 24:21 -p 26:22 -p 8080:80 -v /home/user/www/:/var/www/html/ marvicz/ubuntu-lamp

Get into docker container: ssh -p 26 root@localhost
