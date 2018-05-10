#!/bin/bash

# Network
ping -c 1 -W 3 www.baidu.com &> /dev/null
if [ ! $? = 0 ];then
  echo "Cannot be networked"
  exit 1
fi

echo "
-------------------------------------------
                                          |
  1: Restart all services                 |
  2: Stop all services                    |
  3: Show all service information         |
  4: One-click Installation ops_inception |
                                          |
-------------------------------------------
"

# Set PATH Variables
export PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/root/bin

# Set output color
COLUMENS=80
SPACE_COL=$[ $COLUMENS-21 ]
VERSION=`uname -r | awk -F'.' '{print $1}'`
 
RED='\033[1;5;31m'
GREEN='\033[1;32m'
NORMAL='\033[0m'
 
success() {
  REAL_SPACE=$[ $SPACE_COL - ${#1} ]
  for i in `seq 1 $REAL_SPACE`; do
      echo -n " "
  done
  echo -e "[ ${GREEN}SUCCESS${NORMAL} ]"
}

failure() {
  REAL_SPACE=$[ $SPACE_COL - ${#1} ]
  for i in `seq 1 $REAL_SPACE`; do
      echo -n " "
  done
  echo -e "[ ${RED}FAILURE${NORMAL} ]"
  exit 1
}

help() {
  echo "Please enter a valid serial number" 
}

install() {
# 01
Data="01) Install Dependency Packages, Please wait..."
echo -n $Data
rm -fr /var/run/yum.pid &> /dev/null
yum install -y epel-release wget gcc openssl-devel git python-pip net-tools &> /dev/null
yum install -y zlib zlib-devel tar gzip bzip2 xz zip &>/dev/null && success "$Data" || failure "$Data" 

# 02
Data="02) Install Nginx, Please wait..."
echo -n $Data
yum install -y nginx &>/dev/null && success "$Data" || failure "$Data"

# 03
Data="03) Install MySQL, Please wait..."
echo -n $Data
if [ $VERSION = 2 ];then
echo '
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/6/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo
else
echo '
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo
fi

which mysqld &> /dev/null
if [ $? = 0 ];then
  echo ""
  read -p "MySQL/MariaDB already exists, uninstall and delete data after reinstall[y/n]: " SELECT
  case $SELECT in
    y|Y)
      Data="Remove MySQL, Please wait..."
      echo -n $Data
      yum remove mysql-community-* MariaDB* -y &> /dev/null && success "$Data" || failure "$Data" 
      rm -fr /tmp/mysql_back &> /dev/null
      mv /var/lib/mysql /tmp/mysql_back &> /dev/null
      Data="Install MySQL, Please wait..."
      echo -n $Data
      yum install -y mysql-community-server &>/dev/null && success "$Data" || failure "$Data" 
      ;;
    n|N)
      V=1  
      ;;
    *)
      exit 1
  esac
else
  yum install -y mysql-community-server &>/dev/null && success "$Data" || failure "$Data" 
fi

# 04
Data="04) Install Python 3.6, Please wait..."
echo -n $Data
which python3.6 &> /dev/null
if [ $? = 0 ]; then
  success "$Data"
else
  cd /opt && rm -fr Python-3.6.4.tar.xz &> /dev/null
  wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tar.xz &> /dev/null 
  tar xvf Python-3.6.4.tar.xz &> /dev/null && cd Python-3.6.4
  if [ $? = 0 ];then 
    ./configure &> /dev/null && make &> /dev/null && make install &>/dev/null && success "$Data" || failure "$Data"
  fi
fi

# 05
Data="05) Git Clone ops_inception, Please wait..."
echo -n $Data
cd /opt && rm -fr ops_inception_back &> /dev/null && mv ops_inception ops_inception_back &> /dev/null
git clone git@git.gungunqian.cn:qiangungun/ops_inception.git &>/dev/null || failure "$Data"
cd /opt/ops_inception/src &> /dev/null
pip3 install -r requirements.txt &>/dev/null && success "$Data" || failure "$Data" 

# 06
Data="06) Copy ops_inception File, Please wait..."
echo -n $Data
ps aux | grep runserver | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
rm -fr /usr/share/nginx/html/* &> /dev/null
yes | cp -fnr /opt/ops_inception/install/connections.py /usr/local/lib/python3.6/site-packages/pymysql/ &> /dev/null 
yes | cp -fnr /opt/ops_inception/install/cursors.py /usr/local/lib/python3.6/site-packages/pymysql/ &> /dev/null
yes | cp -fnr /opt/ops_inception/webpage/dist/* /usr/share/nginx/html/ &>/dev/null && success "$Data" || failure "$Data"

# 07
Data="07) Start Nginx, Please wait..."
echo -n $Data
if [ $VERSION = 2 ];then
  service nginx restart &>/dev/null && success "$Data" || failure "$Data"
else
  systemctl restart nginx &>/dev/null && success "$Data" || failure "$Data"
fi  

# 08
Data="08) Start MySQL, Please wait..."
echo -n $Data
if [ $VERSION = 2 ];then
  service mysqld restart &>/dev/null && success "$Data" || failure "$Data"
else
  systemctl restart mysqld &>/dev/null && success "$Data" || failure "$Data" 
fi  

# 09
if [ "$V" = 1 ];then
read -p "09) Input MySQL root Password: " MYSQLPASSWORD
if [ -z $MYSQLPASSWORD ];then
   echo "Input cannot empty, please enter again"
   read -p "Input MySQL root Password: " MYSQLPASSWORD
fi
else
read -p "09) Set MySQL root Password: " MYSQLPASSWORD
if [ -z $MYSQLPASSWORD ];then
   echo "Input cannot empty, please enter again"
   read -p "Set MySQL root Password: " MYSQLPASSWORD
fi
fi

mysql -uroot -e "grant all on *.* to root@localhost identified by '${MYSQLPASSWORD}'; flush privileges;" &> /dev/null
if [ $? = 0 ];then
  mysql -uroot -p"$MYSQLPASSWORD" -e "create database if not exists ops_inception charset utf8;" &> /dev/null
else
  mysql -uroot -p"$MYSQLPASSWORD" -e "create database if not exists ops_inception charset utf8;" &> /dev/null
fi

# 10
ADDRESS=`netstat -anplt | grep "sshd" | grep ESTABLISHED | awk '{print $4}' | awk -F':' '{print $1}' | head -n1`
if [ -z $ADDRESS ];then
  ADDRESS="127.0.0.1"
  read -p "10) Input Localhost IP Address[Default: $ADDRESS]: " ADDRESS 
  if [ -z $ADDRESS ];then
    ADDRESS=`netstat -anplt | grep "sshd" | grep ESTABLISHED | awk '{print $4}' | awk -F':' '{print $1}' | head -n1`
    if [ -z $ADDRESS ];then
      ADDRESS="127.0.0.1"
    fi
  fi
else
  read -p "10) Input Localhost IP Address[Default: $ADDRESS]: " ADDRESS 
  ADDRESS=`netstat -anplt | grep "sshd" | grep ESTABLISHED | awk '{print $4}' | awk -F':' '{print $1}' | head -n1`
fi
cd /opt/ops_inception/src && sed -i "s/backuppassword =.*/backuppassword = $MYSQLPASSWORD/" deploy.conf &> /dev/null
cd /opt/ops_inception/src && sed -i "s/ipaddress = .*/ipaddress = ${ADDRESS}:8000/" deploy.conf &> /dev/null
cd /opt/ops_inception/src && sed -i "s/password =.*/password = $MYSQLPASSWORD/" deploy.conf &> /dev/null 

# 11
Data="11) Migrate ops_inception Tables, Please wait..."
echo -n $Data
cd /opt/ops_inception/src
python3 manage.py makemigrations &> /dev/null && python3 manage.py migrate &> /dev/null && success "$Data" || failure "$Data"

# 12
read -p "12) Set ops_inception admin User Passwrod: " PASSWORD
if [ -z $PASSWORD ];then
   echo -e "Input cannot empty, please enter again"
   read -p "Set ops_inception admin User Passwrod: " PASSWORD
fi
echo "from core.models import Account; Account.objects.create_user(username='admin', password="$PASSWORD", group='admin',is_staff=1)" | python3 manage.py shell &> /dev/null
echo "from core.models import grained;grained.objects.get_or_create(username='admin', permissions={'ddl': '1', 'ddlcon': [], 'dml': '1', 'dmlcon': [], 'dic': '1', 'diccon': [], 'dicedit': '0', 'query': '1', 'querycon': [], 'user': '1', 'base': '1', 'dicexport': '0', 'person': []})" | python3 manage.py shell &> /dev/null

# 13
Data="13) Start Inception, Please wait..."
echo -n $Data
cd /opt/ops_inception/install/ && tar xvf inception.tar &> /dev/null
ps aux | grep Inception | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
/opt/ops_inception/install/inception/bin/Inception --defaults-file=/opt/ops_inception/install/inception/bin/inc.cnf &> /dev/null & 
if [ $? = 0 ];then
  success "$Data" 
else
  failure "$Data"
fi

# 14
Data="14) Start ops_inception, Please wait..."
echo -n $Data
cd /opt/ops_inception/src
ps aux | grep runserver | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
python3 manage.py runserver 0.0.0.0:8000 &> /dev/null &
if [ $? = 0 ];then
  success "$Data" 
else
  failure "$Data"
fi
}

restart() {
  Data="01) Restart Nginx"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service nginx restart &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl restart nginx &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="02) Restart MySQL"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service mysqld restart &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl restart mysqld &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="03) Restart Inception"
  echo -n $Data
  ps aux | grep Inception | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  /opt/ops_inception/install/inception/bin/Inception --defaults-file=/opt/ops_inception/install/inception/bin/inc.cnf &> /dev/null & 
  if [ $? = 0 ];then
    success "$Data" 
  else
    failure "$Data"
  fi
  sleep 1
  
  Data="04) Restart ops_inception"
  echo -n $Data
  cd /opt/ops_inception/src
  ps aux | grep runserver | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  python3 manage.py runserver 0.0.0.0:8000 &> /dev/null &
  if [ $? = 0 ];then
    success "$Data" 
  else
    failure "$Data"
  fi
  echo ""
}

stop() {
  Data="01) Stop Nginx"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service nginx stop &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl stop nginx &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="02) Stop MySQL"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service mysqld stop &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl stop mysqld &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="03) Stop Inception"
  echo -n $Data
  ps aux | grep Inception | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  if [ $? = 0 ];then
    success "$Data" 
  else
    success "$Data"
  fi
  sleep 1
  
  Data="04) Stop ops_inception"
  echo -n $Data
  cd /opt/ops_inception/src
  ps aux | grep runserver | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  if [ $? = 0 ];then
    success "$Data" 
  else
    success "$Data"
  fi
  echo ""
}

show() {
cat <<END;
----------------------------------------------------------------
Nginx conf     |   /etc/nginx/nginx.conf                       |
Nginx data     |   /usr/share/nginx/html/*                     |
MySQL conf     |   /etc/my.cnf                                 |
MySQL data     |   /var/lib/mysql/*                            |
Inception conf |   /opt/ops_inception/install/inception/bin/inc.cnf |
ops_inception conf  |   /opt/ops_inception/src/deploy.conf               |
ops_inception log   |   /opt/ops_inception/src/log/*                     |
----------------------------------------------------------------
END
}


read -p "Please select enter a valid sequence number: " NUMBER
echo
case "$NUMBER" in
  1)
    restart
    ;;
  2)
    stop 
    ;;
  3)
    show
    ;;
  4)
    install
    ;;
  *)
    help
    exit 1
esac


# 13
Data="13) Start Inception, Please wait..."
echo -n $Data
cd /opt/ops_inception/install/ && tar xvf inception.tar &> /dev/null
ps aux | grep Inception | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
/opt/ops_inception/install/inception/bin/Inception --defaults-file=/opt/ops_inception/install/inception/bin/inc.cnf &> /dev/null & 
if [ $? = 0 ];then
  success "$Data" 
else
  failure "$Data"
fi

# 14
Data="14) Start ops_inception, Please wait..."
echo -n $Data
cd /opt/ops_inception/src
ps aux | grep runserver | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
python3 manage.py runserver 0.0.0.0:8000 &> /dev/null &
if [ $? = 0 ];then
  success "$Data" 
else
  failure "$Data"
fi
}

restart() {
  Data="01) Restart Nginx"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service nginx restart &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl restart nginx &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="02) Restart MySQL"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service mysqld restart &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl restart mysqld &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="03) Restart Inception"
  echo -n $Data
  ps aux | grep Inception | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  /opt/ops_inception/install/inception/bin/Inception --defaults-file=/opt/ops_inception/install/inception/bin/inc.cnf &> /dev/null & 
  if [ $? = 0 ];then
    success "$Data" 
  else
    failure "$Data"
  fi
  sleep 1
  
  Data="04) Restart ops_inception"
  echo -n $Data
  cd /opt/ops_inception/src
  ps aux | grep runserver | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  python3 manage.py runserver 0.0.0.0:8000 &> /dev/null &
  if [ $? = 0 ];then
    success "$Data" 
  else
    failure "$Data"
  fi
  echo ""
}

stop() {
  Data="01) Stop Nginx"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service nginx stop &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl stop nginx &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="02) Stop MySQL"
  echo -n $Data
  if [ $VERSION = 2 ];then
    service mysqld stop &>/dev/null && success "$Data" || failure "$Data"
  else
    systemctl stop mysqld &>/dev/null && success "$Data" || failure "$Data"
  fi  
  
  Data="03) Stop Inception"
  echo -n $Data
  ps aux | grep Inception | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  if [ $? = 0 ];then
    success "$Data" 
  else
    success "$Data"
  fi
  sleep 1
  
  Data="04) Stop ops_inception"
  echo -n $Data
  cd /opt/ops_inception/src
  ps aux | grep runserver | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null
  if [ $? = 0 ];then
    success "$Data" 
  else
    success "$Data"
  fi
  echo ""
}

show() {
cat <<END;
----------------------------------------------------------------
Nginx conf     |   /etc/nginx/nginx.conf                       |
Nginx data     |   /usr/share/nginx/html/*                     |
MySQL conf     |   /etc/my.cnf                                 |
MySQL data     |   /var/lib/mysql/*                            |
Inception conf |   /opt/ops_inception/install/inception/bin/inc.cnf |
ops_inception conf  |   /opt/ops_inception/src/deploy.conf               |
ops_inception log   |   /opt/ops_inception/src/log/*                     |
----------------------------------------------------------------
END
}


read -p "Please select enter a valid sequence number: " NUMBER
echo
case "$NUMBER" in
  1)
    restart
    ;;
  2)
    stop 
    ;;
  3)
    show
    ;;
  4)
    install
    ;;
  *)
    help
    exit 1
esac
