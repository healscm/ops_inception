#/bin/bash
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
/usr/bin/mysqld_safe &
sleep 3

if [ ! -d "/var/lib/mysql/ops_inception" ]; then
  mysql -e "create database ops_inception character set 'utf8' collate 'utf8_general_ci' ;"
  python3 manage.py makemigrations
  python3 manage.py migrate
  echo "from core.models import Account; Account.objects.create_user(username='admin', password='123456', group='admin',is_staff=1)" | python3 manage.py shell
fi

sed -i "s/ipaddress =.*/ipaddress=$HOST/" deploy.conf
/usr/sbin/nginx
/opt/ops_inception/install/inception/bin/Inception --defaults-file=/opt/ops_inception/install/inception/bin/inc.cnf &
python3 manage.py runserver 0.0.0.0:8000
