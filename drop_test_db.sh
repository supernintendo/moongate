#!/bin/bash

if [[ `psql -tAc "SELECT 1 FROM pg_database WHERE datname='moongate_test'"` != "1" ]]; then
  echo "ERROR: Database 'moongate_test' does not exist."
  exit
fi

echo -e "\033[0;31mWARNING\033[0m: You are about to drop the Moongate test database. Type \"OK\" to confirm."
read should_drop

if [ "$should_drop" != "OK" ]; then
  exit
fi

echo "Dropping database..."

psql <<EOF
  DROP DATABASE moongate_test;
  DROP ROLE moongate_test;
EOF
