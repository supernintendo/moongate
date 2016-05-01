# Moongate

_A server with a little magic_.

[![Build Status](https://travis-ci.org/supernintendo/moongate.svg?branch=master)](https://travis-ci.org/supernintendo/moongate)
[![Inline docs](http://inch-ci.org/github/supernintendo/moongate.svg?branch=master)](http://inch-ci.org/github/supernintendo/moongate)
[![Gitter](https://badges.gitter.im/supernintendo/moongate.svg)](https://gitter.im/supernintendo/moongate?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

### Overview ###

Moongate is a server and application platform for the [Elixir Programming Language](http://elixir-lang.org/). It provides a DSL (domain-specific language) which allows developers to create synchronized, networked experiences.

### Dependencies ###

* Elixir 1.0.5+
* PostgreSQL 9.3.5+

### Installation ###

Clone this repository, `cd` to its directory and run `./scripts/setup.sh`. This script creates a database, fetches dependencies and runs Ecto migrations. Once this is done, run `iex -S mix` or `mix` to start the server.

### Status ###

Moongate is **young software**. Features may be missing or incomplete and use in production is not supported.

### License ###

[Apache License 2.0](LICENSE.md)
