#!/bin/bash
if [[ `psql -tAc "SELECT 1 FROM pg_database WHERE datname='moongate'"` != "1" ]]; then
  echo "ERROR: Database 'moongate' does not exist."
  exit
fi

echo "WARNING: You are about to drop the database. Type \"OK\" to confirm."
read should_drop

if [ "$should_drop" != "OK" ]; then
  exit
fi

echo "Dropping database..."

psql <<EOF
  DROP DATABASE moongate;
  DROP ROLE moongate;
EOF
