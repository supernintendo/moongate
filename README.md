# Moongate #

A barely working multiplayer game server written in Elixir.

### Features ###

* Newbie code.
* Doesn't work.
* Not ready for production.

### Dependencies ###

* Elixir 1.0.0+
* PostgreSQL 9.3.5+

### Setup ###

1. Create the database
...Make sure PostgreSQL is setup and running. Pull in `./util/setup_db.sql` (use `\i` in `psql` for now).

2. Fetch dependencies.
...`cd` to the main directory and run `mix deps.get`.

3. Run migrations.
...From the same directory run the migrations with `./util/reset_db.sh`.

Run the server with `iex -S mix`. A test client is available in `./pkg/clients`. You can't do much yet.

### Why? ###

I'm using this to play around and learn Elixir, this is not intended as a serious project.