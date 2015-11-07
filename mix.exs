defmodule Moongate.Mixfile do
  use Mix.Project
  Code.compiler_options([ignore_module_conflict: true])

  def project do
    [app: :moongate,
     version: "0.0.1",
     elixir: "~> 1.0.5",
     deps: deps,
     default_task: "run"]
  end

  def application do
    [applications: [:logger, :postgrex, :ecto],
     mod: {Moongate.Application, []}]
  end

  defp deps do
    [
      {:cowboy, "1.0.3"},
      {:ecto, "~> 1.0.2"},
      {:json, "~> 0.3.2"},
      {:pbkdf2, ">= 2.0.0", github: "basho/erlang-pbkdf2"},
      {:postgrex, ">= 0.7.0"},
      {:socket, "~> 0.3.1"},
      {:timex, "~> 0.13.1"},
      {:uuid, "~> 1.1.0"}
    ]
  end
end
