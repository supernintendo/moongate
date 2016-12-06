# Moongate

_A server with a little magic_.

[![Build Status](https://travis-ci.org/supernintendo/moongate.svg?branch=master)](https://travis-ci.org/supernintendo/moongate)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/supernintendo/moongate.svg)](https://beta.hexfaktor.org/github/supernintendo/moongate)
[![Gitter](https://badges.gitter.im/supernintendo/moongate.svg)](https://gitter.im/supernintendo/moongate?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

### Overview ###

Moongate is an experimental web server built in [Elixir](http://elixir-lang.org/). It aims to provide a platform for the development of synchronized experiences using a simple DSL (domain-specific language). Applications built with Moongate (known as _worlds_) follow a simple paradigm:

- **Zones**: Zones are general containers of logic that clients can join and leave. Once within a zone, a client can subscribe to and interact with the zone's rings. _Zone examples: game levels, chat rooms, web app routes, etc._<br>
- **Rings**: Rings are groups of objects. Every object within a ring conforms to a shared schema and set of behavior. Ring members can be added, removed and mutated dynamically. _Ring examples: characters, messages, photo uploads, etc._<br>
- **Deeds**: Deeds provide business logic for rings. When a ring implements a deed, all of the deed's public functions are callable by clients subscribed to the ring using Moongate's packet language. A deed can be implemented by more than one ring to allow shared behavior. _Deed examples: movement, mute settings, image cropper, etc._

Moongate supports WebSockets out-of-the-box but is protocol agnostic (packet encoding, decoding and session management are decoupled from networking). A reference client written in JavaScript is included. 

### Dependencies ###

* [Erlang 18](https://www.erlang.org/downloads/18.0)
* [rebar3](https://www.rebar3.org/)

### Setup ###

1. Clone this repo anywhere as a non-privileged user.
2. `cd` to the directory where you cloned Moongate and run `./moongate`.
3. Open a web browser and go to [localhost:5920](http://localhost:5920/).

If it worked, you should see the default Moongate page. Open a second web browser and click anywhere on the page to move your character. The character should move on both browser windows.

### Project Status ###

You might think of Moongate as a learning experience that is slowly evolving. Progress is very ephemeral. As usual, features may be missing and bugs are certainly present.

### License ###

[Apache License 2.0](LICENSE.md)
