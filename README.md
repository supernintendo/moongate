# Moongate #

A work-in-progress multiplayer game server and client implementation.

### Dependencies ###

* Elixir 1.0.0+
* PostgreSQL 9.3.5+
* LÖVE 0.9.1

### Server Setup ###

1. Create the database
... Make sure PostgreSQL is setup and running. Run `./util/setup_db.sql` in `psql`.

2. Fetch dependencies.
... Run `mix deps.get` in the main directory.

3. Run migrations.
... Run `./util/reset_db.sh` from the main directory to run migrations.

Run the server with `iex -S mix`.

### Client Setup ###

1. Install dependencies.
... Run `./deps.sh` from the `client` directory.

### License ###

MIT