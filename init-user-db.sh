#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER $DATABASE_USERNAME with encrypted password '$DATABASE_PASSWORD';
  CREATE USER mainpower;
	CREATE DATABASE i5_test WITH OWNER $DATABASE_USERNAME;
	CREATE DATABASE i5_development WITH OWNER $DATABASE_USERNAME;
	GRANT ALL PRIVILEGES ON DATABASE "i5_test" TO $DATABASE_USERNAME;
	GRANT ALL PRIVILEGES ON DATABASE "i5_development" TO $DATABASE_USERNAME;
  GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DATABASE_USERNAME;
	ALTER USER sysi5adm CREATEDB;
EOSQL