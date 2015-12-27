#!/bin/bash

psql << EOF
  CREATE EXTENSION IF NOT EXISTS dblink;

  DO
  \$body\$
  DECLARE
      match_users integer;
      match_dbs   integer;
  BEGIN
      SELECT count(*)
        into match_users
      FROM pg_user
      WHERE usename = 'moongate';

      SELECT 1
        into match_dbs
      FROM pg_database
      WHERE datname = 'moongate';

      IF match_users > 0 THEN
          RAISE NOTICE 'User already exists';
      ELSE
          CREATE ROLE moongate LOGIN PASSWORD 'moongate';
      END IF;

      IF match_dbs > 0 THEN
          RAISE NOTICE 'Database already exists';
      ELSE
          PERFORM dblink_exec('dbname=' || current_database()
                              , \$\$CREATE DATABASE moongate\$\$);
      END IF;

      ALTER USER moongate WITH SUPERUSER;
  END
  \$body\$
  ;
EOF
