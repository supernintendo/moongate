defmodule Moongate.Mixfile do
  use Mix.Project
  Code.compiler_options([ignore_module_conflict: true])

  def project do
    [app: :moongate,
     version: "0.2.0",
     codename: "Novice",
     elixir: "1.3.2",
     deps: deps,
     default_task: "run"]
  end

  def application do
    [applications: [:bunt, :logger, :porcelain],
     mod: {Moongate.Application, []}]
  end

  defp deps do
    [
      {:bunt, "~> 0.1.0"},
      {:cowboy, "1.0.3"},
      {:earmark, "~> 0.1", only: :dev},
      {:eon, ">= 2.0.0"},
      {:ex_doc, "~> 0.11", only: :dev},
      {:hackney, "1.3.2"},
      {:hexate,  ">= 0.6.0"},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:json, "~> 0.3.2"},
      {:pbkdf2, ">= 2.0.0", github: "basho/erlang-pbkdf2"},
      {:moebius, "~> 2.0.0"},
      {:porcelain, "~> 2.0"},
      {:socket, "~> 0.3.1"},
      {:uuid, "~> 1.1.0"}
    ]
  end
end
