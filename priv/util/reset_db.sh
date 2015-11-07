#!/bin/bash

mix ecto.rollback Db.Repo --all
mix ecto.migrate Db.Repo
