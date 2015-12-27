#!/bin/bash

if [[ `psql -tAc "SELECT 1 FROM pg_database WHERE datname='moongate_test'"` != "1" ]]; then
  echo "ERROR: Database 'moongate_test' does not exist."
  exit
fi

mix ecto.rollback Moongate.Repo --all -c "config/test.exs"
mix ecto.migrate Moongate.Repo -c "config/test.exs"
