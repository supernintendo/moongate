# Moongate #

A work-in-progress multiplayer game server.

### Status ###

Moongate is currently in early development; think of this as the "blueprint" phase. Don't expect this to be useful for a while as features are incomplete or missing and documentation is sparse.

### Dependencies ###

* Elixir 1.0.0+
* PostgreSQL 9.3.5+

### Server Setup ###

1. Create the database
... Make sure PostgreSQL is setup and running. Run `./util/setup_db.sql` in `psql`.

2. Fetch dependencies.
... Run `mix deps.get` in the main directory.

3. Run migrations.
... Run `./util/reset_db.sh` from the main directory to run migrations.

Run the server with `mix`.

### License ###

MIT