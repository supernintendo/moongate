# Moongate

Moongate is a multiplayer game server and software development kit in early development. It provides a framework for building synchronized experiences using [Elixir](http://elixir-lang.org/).

1. [Overview](#overview)
2. [Setup](#installation)
3. [Getting Started](#getting-started)

## Setup

### Minimum Requirements ###

* [Erlang/OTP 20](https://www.erlang.org/)

### Installation ###

```bash
git clone https://github.com/supernintendo/moongate ~/Moongate && \
  cd ~/Moongate && \
  ./moongate install
```
Follow the prompt to fetch and setup dependencies, or download and install them manually:

* [Elixir 1.4.5](https://elixir-lang.org/)
* [Redis 4.0.0](https://redis.io/)
* [Rust 1.17.0](https://elixir-lang.org/)
* [Node.js >= 7.0.0](https://nodejs.org/en/)<sup>1</sup>

<sup>1</sup> <small>(optional, for Moongate.js development)</small>

Once Moongate is installed, run `./moongate test` to make sure everything was configured properly. ExUnit should complete with `0 failures`.

## Getting Started

### Example Project

- Run `./moongate load orbs` to start the example project.
- Navigate to [localhost:7778](http://localhost:7778/) in your browser.
- Open a second browser window to the same page.
- Click to move the orb. You should see its position update on the other window.

Check the `games` directory for examples of projects built with Moongate.

### License ###

[Apache License 2.0](LICENSE.md)
