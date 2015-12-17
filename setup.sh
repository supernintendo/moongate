#!/bin/bash

./setup_db.sh
mix deps.get
mix ecto.migrate Moongate.Repo
