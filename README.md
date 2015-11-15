# Moongate #

![Moongate](https://i.giphy.com/3o85xqvMA3Clzv4zw4.gif)

A framework for multiplayer game servers written in Elixir.

### Overview ###

This project is intended to be a platform for building multiplayer game servers. Moongate contains an Elixir DSL for managing game state and communicating with clients. It aims to provide a simple backbone for your serverside code:

- *Pools* - Pools contain the objects that make up your game world. Members of a pool have attributes that can be mutated over time (for example, a `Character`'s movement).
- *Stages* - Stages are essentially a collection of pools. Game clients can join stages, allowing them to send messages to the pools within as well as synchronize with their state.

Moongate supports TCP, UDP and WebSockets. It includes a JavaScript library `moongate.js` as a reference for client-side communication with Moongate.

### Status ###

Moongate is currently in early development. Things are changing and features may be missing or incomplete.

### Dependencies ###

* Elixir 1.0.5+
* PostgreSQL 9.3.5+

### License ###

MIT
