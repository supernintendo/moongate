# Moongate #

![Moongate](https://media.giphy.com/media/3o85xL99sAjXZLE7eM/giphy.gif)

A framework for multiplayer game servers written in Elixir.

### Overview ###

This project is intended to be a platform for building multiplayer game servers. Moongate contains an Elixir DSL for managing game state and communicating with clients. It aims to provide a simple backbone for your serverside code:

- *Pools* - Pools contain the objects that make up your game world. Examples range from collections (characters, items, projectiles, etc.) to singular entities (weather, gravity, and so on).
- *Stages* - Stages contain pools. Clients can join stages and listen to pools as well as trigger events on them.

Moongate supports TCP, UDP and WebSockets and uses [Cowboy](https://github.com/ninenines/cowboy) to serve static web assets.

### Status ###

Moongate is currently in early development. Things are changing and features may be missing or incomplete.

### Dependencies ###

* Elixir 1.0.5+
* PostgreSQL 9.3.5+

### License ###

MIT