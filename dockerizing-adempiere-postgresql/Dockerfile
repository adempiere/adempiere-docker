# Dockerfile for ADempiere 380 with PostgreSQL 9.3

FROM ubuntu
MAINTAINER victor.perez@e-evolution.com

USER root

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.3
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 wget openssh-server

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Install Java.
RUN \
  apt-get update && \
  apt-get install -y openjdk-7-jdk && \
  rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
RUN mkdir /data/app
RUN chmod -R 777 /data/app

RUN mkdir /var/run/sshd
RUN echo 'root:adempiere' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

RUN wget http://hg.code.sf.net/p/adempiere/code/raw-file/525f6fdbba3a/install/build/Adempiere_380LTS.tar.gz -O /data/app/Adempiere_380LTS.tar.gz
RUN cd /data/app && tar -zxvf /data/app/Adempiere_380LTS.tar.gz -C /data/app/
RUN sudo chmod -R 777 /data/app
RUN sed "s/ADEMPIERE_HOME=C*....Adempiere/ADEMPIERE_HOME=\/data\/app\/Adempiere/g" /data/app/Adempiere/AdempiereEnvTemplate.properties > /data/app/Adempiere/AdempiereEnv.tmp.1
RUN sed "s/JAVA_HOME=C*..................................../JAVA_HOME=\/usr\/lib\/jvm\/java-7-openjdk-amd64/g" /data/app/Adempiere/AdempiereEnv.tmp.1 > /data/app/Adempiere/AdempiereEnv.tmp.2
RUN sed "s/ADEMPIERE_APPS_SERVER=localhost/ADEMPIERE_APPS_SERVER=adempiere-pg/g" /data/app/Adempiere/AdempiereEnv.tmp.2 > /data/app/Adempiere/AdempiereEnv.tmp.3
RUN sed "s/ADEMPIERE_KEYSTORE=C*..................................../ADEMPIERE_KEYSTORE=\/data\/app\/Adempiere\/keystore\/myKeystore/g" /data/app/Adempiere/AdempiereEnv.tmp.3 > /data/app/Adempiere/AdempiereEnv.properties
RUN cat /data/app/Adempiere/AdempiereEnv.properties
ENV ADEMPIERE_HOME /data/app/Adempiere/
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64


# Adjust PostgreSQL configuration so that remote connections to the
# database are possible. 

RUN sed "s/local   all             postgres                                peer/local   all             postgres                                trust/g" /etc/postgresql/9.3/main/pg_hba.conf > /etc/postgresql/9.3/main/pg_hba.tmp.1 
RUN sed "s/local   all             all                                     peer/local   all             all                                     trust/g" /etc/postgresql/9.3/main/pg_hba.tmp.1 > /etc/postgresql/9.3/main/pg_hba.tmp.2
RUN sed "s/host    all             all             127.0.0.1\/32            md5/host    all             all             $(hostname -i)\/32            trust/g" /etc/postgresql/9.3/main/pg_hba.tmp.2 > /etc/postgresql/9.3/main/pg_hba.tmp.3
RUN sed "s/host    all             all             127.0.0.1\/32            md5/host    all             all             127.0.0.1\/32            trust/g" /etc/postgresql/9.3/main/pg_hba.tmp.3 > /etc/postgresql/9.3/main/pg_hba.tmp.4
RUN sed "s/host    all             all             ::1\/128                 md5/host    all             all             ::1\/128                 trust/g" /etc/postgresql/9.3/main/pg_hba.tmp.4 > /etc/postgresql/9.3/main/pg_hba.conf

RUN echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
#RUN echo "host all all $(hostname -i)/24 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
# Create a PostgreSQL role named ``adempiere`` with ``adempiere`` as the password and
# then create a database `adempiere` owned by the ``adempiere`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN echo "ALTER USER postgres WITH PASSWORD 'postgres'; " >> /data/app/pg_setup.sql
RUN echo "CREATE USER adempiere WITH SUPERUSER PASSWORD 'adempiere';"  >> /data/app/pg_setup.sql
RUN echo "UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';" >> /data/app/pg_setup.sql
RUN echo "DROP DATABASE template1; " >> /data/app/pg_setup.sql
RUN echo "CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';" >> /data/app/pg_setup.sql
RUN echo "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';" >> /data/app/pg_setup.sql
RUN echo "CREATE DATABASE adempiere OWNER adempiere ENCODING 'UNICODE' TEMPLATE template1;"  >> /data/app/pg_setup.sql;
RUN cat /data/app/pg_setup.sql
RUN /etc/init.d/postgresql restart && psql -U postgres < /data/app/pg_setup.sql && cd /data/app/Adempiere/ && ./RUN_silentsetup.sh && cd /data/app/Adempiere/utils/ && ./RUN_ImportAdempiere.sh
RUN echo "#!/bin/bash" >> /data/app/start.sh
RUN echo "/etc/init.d/postgresql restart" >> /data/app/start.sh
RUN echo "/data/app/Adempiere/utils/RUN_Server2.sh" >> /data/app/start.sh
RUN chmod 777 /data/app/start.sh
RUN cat /data/app/start.sh
# Expose the PostgreSQL port
USER postgres
#RUN    /etc/init.d/postgresql start 
EXPOSE 5432
# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql" ]
#CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
USER root
EXPOSE 80
EXPOSE 443
CMD ["/data/app/start.sh"]
