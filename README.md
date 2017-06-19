# Moongate

[![Build Status](https://travis-ci.org/supernintendo/moongate.svg?branch=master)](https://travis-ci.org/supernintendo/moongate)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/supernintendo/moongate.svg)](https://beta.hexfaktor.org/github/supernintendo/moongate)
[![Gitter](https://badges.gitter.im/supernintendo/moongate.svg)](https://gitter.im/supernintendo/moongate?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Moongate is a multiplayer game server and software development kit. It provides a framework for building synchronized experiences using [Elixir](http://elixir-lang.org/) and [Rust](https://www.rust-lang.org/en-US/).

1. [Overview](#overview)
2. [Setup](#installation)
3. [Getting Started](#getting-started)

## Overview



## Setup

### Minimum Requirements ###

* [Erlang 19](https://www.erlang.org/)+
* [rebar3](https://www.rebar3.org/)

### Installation ###

```bash
git clone https://github.com/supernintendo/moongate ~/Moongate && \
  cd ~/Moongate && \
  ./moongate install
```
Follow the prompt to fetch and setup dependencies, or download and install them manually:

* [Elixir 1.4.4](https://elixir-lang.org/)
* [Rust 1.4.4](https://elixir-lang.org/)
* [Node.js >= 7.0.0](https://nodejs.org/en/)<sup>1</sup>

<sup>1</sup> <small>(recommended for beginners; enables Moongate.js and bundled Electron client)</small>

## Getting Started

### Example Project

Before creating a new project, make sure Moongate has been setup properly:

- Run `./moongate test`. ExUnit should run with `0 failures`.
- Run `./moongate load orbs` to start the example project.
- Navigate to [localhost:7778](http://localhost:7778/) in your browser or type `mg Client` in the IEx prompt.
- Repeat the previous step to open a second session.
- Click to move the orb. You should see it move on the other window.

### New Project

To create a blank project, run <code>./moongate new _game\_name_</code>. A new directory with the name `game_name` will be created with the following project structure (it will be placed in the `games` directory if ran from within a subdirectory of Moongate).

```
├── client
│   ├── index.html
│   ├── index.js
├── game.ex
├── moongate.json
├── rings
│   └── player.ex
├── rules
└── zones
    └── level.ex
```

### License ###

[Apache License 2.0](LICENSE.md)
