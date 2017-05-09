FROM wnameless/xe-temp

MAINTAINER victor.perez <victor.perez@e-evolution.com>

ADD chkconfig /sbin/chkconfig
ADD init.ora /
ADD initXETemp.ora /

RUN apt-get install -y libaio1 net-tools bc
RUN ln -s /usr/bin/awk /bin/awk
RUN mkdir /var/lock/subsys
RUN chmod 755 /sbin/chkconfig
RUN cat /etc/mtab
#RUN ln -s /proc/mounts /etc/mtab

RUN dpkg --install /tmp/oracle-xe_11.2.0-1.0_amd64.deb

RUN mv /init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts
RUN mv /initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts

RUN printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

RUN echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bash.bashrc
RUN echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc
RUN echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc

EXPOSE 22
EXPOSE 1521
EXPOSE 8080

CMD sed -i -E "s/HOST = [^)]+/HOST = adempiere-oracle/g" /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora &&
sed -i -E "s/HOST = [^)]+/HOST = adempiere-oracle/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora; \
	service oracle-xe start


RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 437D05B5 3E5C1192
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise universe" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update

# Install Java.
RUN \
  apt-get update && \
  apt-get install -y openjdk-7-jdk && \
  rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /u01/app/Adempiere

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
#RUN mkdir /data/app
#RUN chmod -R 777 /data/app

RUN wget http://dl.bintray.com/adempiere/Official-Repository/Adempiere_380LTS.tar.gz -O /u01/app/Adempiere_380LTS.tar.gz
RUN cd /u01/app && tar -zxvf /u01/app/Adempiere_380LTS.tar.gz -C /u01/app/
RUN chmod -R 777 /u01/app/Adempiere
RUN sed "s/ADEMPIERE_HOME=C*....Adempiere/ADEMPIERE_HOME=\/u01\/app\/Adempiere/g" /u01/app/Adempiere/AdempiereEnvTemplate.properties > /u01/app/Adempiere/AdempiereEnv.tmp.1
RUN sed "s/JAVA_HOME=C*..................................../JAVA_HOME=\/usr\/lib\/jvm\/java-7-openjdk-amd64/g" /u01/app/Adempiere/AdempiereEnv.tmp.1 > /u01/app/Adempiere/AdempiereEnv.tmp.2
RUN sed "s/ADEMPIERE_APPS_SERVER=localhost/ADEMPIERE_APPS_SERVER=adempiere-oracle/g" /u01/app/Adempiere/AdempiereEnv.tmp.2 > /u01/app/Adempiere/AdempiereEnv.tmp.3
RUN sed "s/ADEMPIERE_DB_TYPE=postgresql/ADEMPIERE_DB_TYPE=oracleXE/g" /u01/app/Adempiere/AdempiereEnv.tmp.3 > /u01/app/Adempiere/AdempiereEnv.tmp.4
RUN sed "s/ADEMPIERE_DB_PATH=postgresql/ADEMPIERE_DB_PATH=oracleXE/g" /u01/app/Adempiere/AdempiereEnv.tmp.4 > /u01/app/Adempiere/AdempiereEnv.tmp.5
RUN sed "s/ADEMPIERE_DB_SERVER=localhost/ADEMPIERE_DB_SERVER=adempiere-oracle/g" /u01/app/Adempiere/AdempiereEnv.tmp.5 > /u01/app/Adempiere/AdempiereEnv.tmp.6
RUN sed "s/ADEMPIERE_DB_PORT=5432/ADEMPIERE_DB_PORT=1521/g" /u01/app/Adempiere/AdempiereEnv.tmp.6 > /u01/app/Adempiere/AdempiereEnv.tmp.7
RUN sed "s/ADEMPIERE_DB_NAME=adempiere/ADEMPIERE_DB_NAME=XE/g" /u01/app/Adempiere/AdempiereEnv.tmp.7 > /u01/app/Adempiere/AdempiereEnv.tmp.8
RUN sed "s/ADEMPIERE_DB_SYSTEM=postgres/ADEMPIERE_DB_SYSTEM=oracle/g" /u01/app/Adempiere/AdempiereEnv.tmp.8 > /u01/app/Adempiere/AdempiereEnv.tmp.9
RUN sed "s/ADEMPIERE_DB_URL=@ADEMPIERE_DB_URL@/ADEMPIERE_DB_URL=XE/g" /u01/app/Adempiere/AdempiereEnv.tmp.9 > /u01/app/Adempiere/AdempiereEnv.tmp.10
RUN sed "s/ADEMPIERE_KEYSTORE=C*..................................../ADEMPIERE_KEYSTORE=\/u01\/app\/Adempiere\/keystore\/myKeystore/g" /u01/app/Adempiere/AdempiereEnv.tmp.10 > /u01/app/Adempiere/AdempiereEnv.properties
RUN cat /u01/app/Adempiere/AdempiereEnv.properties
ENV ADEMPIERE_HOME /u01/app/Adempiere/
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
ENV export PATH=$ORACLE_HOME/bin:$PATH
ENV export ORACLE_SID=XE

RUN cd /u01/app/Adempiere/ && ./RUN_silentsetup.sh && cd /u01/app/Adempiere/utils/
&& ./RUN_ImportAdempiere.sh
RUN echo "#!/bin/bash" >> /u01/app/start.sh
RUN echo "/etc/init.d/oracle-xe restart" >> /u01/app/start.sh
RUN echo "/u01/app/Adempiere/utils/RUN_Server2.sh" >> /u01/app/start.sh
RUN chmod 777 /u01/app/start.sh
RUN cat /u01/app/start.sh
VOLUME  ["/u01/app/Adempiere"]
CMD /usr/sbin/sshd -D
#CMD ["/01/app/start.sh"]
