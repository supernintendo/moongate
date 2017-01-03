defmodule Moongate.Mixfile do
  use Mix.Project
  Code.compiler_options([ignore_module_conflict: true])

  @codename File.read!("priv/metadata/codename") |> String.strip
  @elixir_version File.read!("priv/metadata/elixir_version") |> String.strip
  @version File.read!("priv/metadata/version") |> String.strip

  def project do
    [
      app: :moongate,
      version: @version,
      codename: @codename,
      elixir: @elixir_version,
      deps: deps,
      default_task: "run"
    ]
  end

  def application do
    [
      applications: [
        :bunt,
        :cowboy,
        :eon,
        :hexate,
        :inflex,
        :json,
        :logger,
        :pbkdf2,
        :poison,
        :uuid
      ],
      mod: {Moongate, []}
    ]
  end

  defp deps do
    [
      {:bunt, "~> 0.1.0"},
      {:cowboy, github: "ninenines/cowboy", tag: "2.0.0-pre.3"},
      {:distillery, "~> 1.0"},
      {:eon, ">= 2.0.0"},
      {:inflex, "~> 1.7.0"},
      {:hexate,  ">= 0.6.0"},
      {:json, "~> 0.3.2"},
      {:pbkdf2, ">= 2.0.0", github: "basho/erlang-pbkdf2"},
      {:poison, "~> 3.0"},
      {:uuid, "~> 1.1.0"}
    ]
  end
end
