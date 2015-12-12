#!/bin/bash

./priv/util/setup_db.sh
mix deps.get
mix ecto.migrate Moongate.Repo
