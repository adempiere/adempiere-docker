FROM eclipse-temurin:17
MAINTAINER raul.capecce@openupsolutions.com , victor.perez@e-evolution.com

ARG ADEMPIERE_BINARY
ARG ADEMPIERE_SRC_DIR
ARG ADEMPIERE_DB_HOST
ARG ADEMPIERE_DB_PORT
ARG ADEMPIERE_DB_NAME
ARG ADEMPIERE_DB_USER
ARG ADEMPIERE_DB_PASSWORD
ARG ADEMPIERE_DB_ADMIN_PASSWORD
ARG ADEMPIERE_WEB_PORT

ENV ADEMPIERE_BINARY $ADEMPIERE_BINARY
ENV ADEMPIERE_SRC_DIR $ADEMPIERE_SRC_DIR
ENV ADEMPIERE_DB_HOST $ADEMPIERE_DB_HOST
ENV ADEMPIERE_DB_PORT $ADEMPIERE_DB_PORT
ENV ADEMPIERE_DB_NAME $ADEMPIERE_DB_NAME
ENV ADEMPIERE_DB_USER $ADEMPIERE_DB_USER
ENV ADEMPIERE_DB_PASSWORD $ADEMPIERE_DB_PASSWORD
ENV ADEMPIERE_DB_ADMIN_PASSWORD $ADEMPIERE_DB_ADMIN_PASSWORD
ENV ADEMPIERE_WEB_PORT $ADEMPIERE_WEB_PORT

ENV ADEMPIERE_HOME /opt/Adempiere
ENV AD_DB_Init $AD_DB_Init
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:17 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

COPY $ADEMPIERE_SRC_DIR/$ADEMPIERE_BINARY /tmp
COPY $ADEMPIERE_SRC_DIR/lib /tmp/lib
COPY $ADEMPIERE_SRC_DIR/packages /tmp/packages
COPY ./adempiere-last/start-adempiere.sh /root
COPY ./adempiere-last/define-ad-ctl.sh /root

RUN cd /tmp && \
tar zxvf /tmp/$ADEMPIERE_BINARY && \
mv Adempiere /opt/Adempiere && \
mv lib /opt/Adempiere/lib && \
mv packages /opt/Adempiere/packages && \
chmod -Rf 755 /opt/Adempiere/*.sh && \
chmod -Rf 755 /opt/Adempiere/utils/*.sh && \
cp /opt/Adempiere/AdempiereEnvTemplate.properties /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/JAVA_HOME=\/usr\/lib\/jvm\/jdk-11/JAVA_HOME=\/opt\/java\/openjdk/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_JAVA_OPTIONS=-Xms64M -Xmx512M/ADEMPIERE_JAVA_OPTIONS=-Xms1024M -Xmx4096M/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_APPS_TYPE=tomcat/ADEMPIERE_APPS_TYPE=jetty/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_APPS_PATH=\/opt\/tomcat/ADEMPIERE_APPS_PATH=\/opt\/jetty-home-10.0.7/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_APPS_SERVER=localhost/ADEMPIERE_APPS_SERVER=$(hostname)/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_DB_SERVER=localhost/ADEMPIERE_DB_SERVER=$ADEMPIERE_DB_HOST/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_DB_PORT=5432/ADEMPIERE_DB_PORT=$ADEMPIERE_DB_PORT/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_DB_NAME=adempiere/ADEMPIERE_DB_NAME=$ADEMPIERE_DB_NAME/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_DB_USER=adempiere/ADEMPIERE_DB_USER=$ADEMPIERE_DB_USER/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_DB_PASSWORD=adempiere/ADEMPIERE_DB_PASSWORD=$ADEMPIERE_DB_PASSWORD/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_DB_SYSTEM=postgres/ADEMPIERE_DB_SYSTEM=$ADEMPIERE_DB_ADMIN_PASSWORD/g" /opt/Adempiere/AdempiereEnv.properties && \
sed -i "s/ADEMPIERE_KEYSTORE=*/ADEMPIERE_KEYSTORE=keystore\/myKeystore/g" /opt/Adempiere/AdempiereEnv.properties && \
echo "ADEMPIERE_DB_URL=jdbc\:postgresql\://$ADEMPIERE_DB_HOST\:$ADEMPIERE_DB_PORT/$ADEMPIERE_DB_NAME" >> /opt/Adempiere/AdempiereEnv.properties && \
echo "CDate=`date +%y%m%d%H%M%S`" >> /opt/Adempiere/AdempiereEnv.properties && \
JAVA_HOME="/opt/java/openjdk" && \
chmod +x /root/define-ad-ctl.sh && sync && \
/root/define-ad-ctl.sh && sync && \
cd /opt/Adempiere && \
apt update && \
apt -y install curl ca-certificates gnupg lsb-core && \
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null && \
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
apt update && \
apt install -y postgresql-client postgresql-contrib && \
cd /opt && \
curl https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/10.0.7/jetty-home-10.0.7.tar.gz --output jetty-home-10.0.7.tar.gz && \
tar -zxvf jetty-home-10.0.7.tar.gz && \
JETTY_HOME=/opt/jetty-home-10.0.7 && \
chmod 755 /root/start-adempiere.sh && \
chmod 755 /opt/Adempiere/*.sh && \
ls -la  /opt/Adempiere/lib
CMD /root/start-adempiere.sh > /tmp/start-adempiere.log