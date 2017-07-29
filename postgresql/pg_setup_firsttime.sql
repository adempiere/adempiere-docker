ALTER USER postgres WITH PASSWORD 'postgres';
DROP USER adempiere
CREATE USER adempiere WITH SUPERUSER PASSWORD 'adempiere';
UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';
DROP DATABASE template1;
CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';
CREATE DATABASE adempiere OWNER adempiere ENCODING 'UNICODE' TEMPLATE template1;
