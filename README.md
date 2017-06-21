# Moongate

Moongate is a multiplayer game server and software development kit. It provides a framework for building synchronized experiences using [Elixir](http://elixir-lang.org/).

1. [Overview](#overview)
2. [Setup](#installation)
3. [Getting Started](#getting-started)

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
* [Rust 1.17.0](https://elixir-lang.org/)
* [Node.js >= 7.0.0](https://nodejs.org/en/)<sup>1</sup>

<sup>1</sup> <small>(optional, enables bundled Electron client)</small>

Once Moongate is installed, run `./moongate test` to make sure everything was configured properly. ExUnit should complete with `0 failures`.

## Getting Started

### Example Project

- Run `./moongate load orbs` to start the example project.
- Navigate to [localhost:7778](http://localhost:7778/) in your browser or type `mg Client` in the IEx prompt.
- Repeat the previous step to open a second session.
- Click to move the orb. You should see it move on the other window.

Check the `games/orbs` directory for an example of how to set up a new Moongate project.

### License ###

[Apache License 2.0](LICENSE.md)
