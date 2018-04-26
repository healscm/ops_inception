FROM centos

MAINTAINER devops

EXPOSE 8000

EXPOSE 80

WORKDIR /tmp

RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
    rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm && \
    yum -y install wget gcc nginx mysql-community-server zlib* openssl-devel git; yum clean all

RUN wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tar.xz && tar xvf Python-3.6.4.tar.xz && \
    cd Python-3.6.4 && ./configure && make && make install && \
    rm -rf /tmp/Python* && mysql_install_db && chmod -R 777 /var/lib/mysql 

WORKDIR /opt/


RUN git clone git@git.gungunqian.cn:qiangungun/ops.git&& \
    cd /opt/ops/src && pip3 install -r requirements.txt && \
    cp -rf /opt/ops/install/connections.py /usr/local/lib/python3.6/site-packages/pymysql/ && \
    cp -rf /opt/ops/install/cursors.py /usr/local/lib/python3.6/site-packages/pymysql/ && \
    cp -rf /opt/ops/install/docker_start.sh /usr/local/bin/ && \ 
    cp -rf /opt/ops/webpage/dist/* /usr/share/nginx/html/ && \
    cd /opt/ops/install/ && tar xvf inception.tar && \
    chmod 755 /usr/local/bin/docker_start.sh

WORKDIR /opt/ops/src

ENTRYPOINT docker_start.sh
