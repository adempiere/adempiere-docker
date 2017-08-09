FROM adpg:9.6
MAINTAINER raul.capecce@openupsolutions.com


ENV PG_VERSION 9.6

ARG PG_Port
ARG PG_DBName
ARG PG_AdempierePsw
ARG PG_PGAdminPsw
ARG PG_MaxConnections
ARG PG_Net
ARG PG_NetMask

ENV PG_PGAdminPsw $PG_PGAdminPsw
ENV PG_AdempierePsw $PG_AdempierePsw
ENV PG_MaxConnections $PG_MaxConnections
ENV PG_Net $PG_Net
ENV PG_NetMask $PG_NetMask

COPY start-postgres.sh /root

RUN chmod +x /root/start-postgres.sh

EXPOSE $PG_Port 5432

CMD /root/start-postgres.sh

