FROM ubuntu:16.04
MAINTAINER raul.capecce@openupsolutions.com


ENV PG_VERSION 9.6


RUN apt-get update && apt-get install sudo wget vim apt-utils -y && \
echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
apt-key add - && \
apt-get update && \
apt-get install postgresql-$PG_VERSION -y && \
apt-get clean

