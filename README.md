# Moongate #

_A game server for the modern era_.

[![Build Status](https://travis-ci.org/supernintendo/moongate.svg?branch=master)](https://travis-ci.org/supernintendo/moongate)
[![Gitter](https://badges.gitter.im/supernintendo/moongate.svg)](https://gitter.im/supernintendo/moongate?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Inline docs](http://inch-ci.org/github/supernintendo/moongate.svg)](https://inch-ci.org/github/supernintendo/moongate)

### Overview ###

Moongate is a multiplayer game server written in Elixir. It contains a DSL for managing game state and communicating with clients, providing a simple backbone for your serverside code.

Moongate supports TCP, UDP and WebSockets. A JavaScript client is included, allowing you to write multiplayer web games out of the box.

<!--A guide on how to get started with Moongate can be found [here](). Full API documentation is [provided as well]().-->

### Installing ###
Make sure you have the following dependencies:

* Elixir 1.0.5+
* PostgreSQL 9.3.5+

Once you do, simply clone this repository, `cd` to its directory and run `./scripts/setup.sh`. This script creates a database, fetches dependencies and runs Ecto migrations.

### Running ###
Simply use `iex -S mix` for now. Deployment and running in production is not currently supported.

### Status ###

Moongate is **early software**. At this time, future versions are not guaranteed to be backwards compatible.

### Attribution ###

This repository contains art from the following asset packs:

* [16x16 Oblique Tileset by DENZI](http://opengameart.org/content/denzis-16x16-oblique-tilesets)
* [Blowhard 2: Blow Harder by Carl Olsson](http://opengameart.org/content/blowhard-2-blow-harder)
* [RogueLite by LD](http://opengameart.org/content/roguelite)

### License ###

[Apache License 2.0](LICENSE.md)
