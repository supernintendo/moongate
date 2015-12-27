#!/bin/bash

source $(dirname $0)/setup_db.sh
source $(dirname $0)/setup_test_db.sh
mix deps.get
mix ecto.migrate Moongate.Repo
mix ecto.migrate Moongate.Repo -c "config/test.exs"
