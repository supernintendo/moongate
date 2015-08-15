defmodule Moongate.Mixfile do
  use Mix.Project

  def project do
    [app: :moongate,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps,
     default_task: "moongate.up"]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :postgrex, :ecto],
     mod: {Moongate, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:socket, "~> 0.2.8"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 0.15.0"},
      {:uuid, "~> 0.1.5"},
      {:pbkdf2, ">= 2.0.0", github: "basho/erlang-pbkdf2"},
      {:timex, "~> 0.13.1"},
      {:json, "~> 0.3.0"},
      {:cauldron, "~> 0.1.2"},
      {:vex, "~> 0.5"}
    ]
  end
end
