#!/bin/bash

./setup_db.sh
./setup_test_db.sh
mix deps.get
mix ecto.migrate Moongate.Repo
mix ecto.migrate Moongate.Repo -c "config/test.exs"
