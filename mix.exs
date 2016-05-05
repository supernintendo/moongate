defmodule Moongate.Mixfile do
  use Mix.Project
  Code.compiler_options([ignore_module_conflict: true])

  def project do
    [app: :moongate,
     version: "0.1.1",
     codename: "Neophyte",
     elixir: "1.2.3",
     deps: deps,
     default_task: "run"]
  end

  def application do
    [applications: [:logger, :postgrex, :ecto, :tzdata],
     mod: {Moongate.Application, []}]
  end

  defp deps do
    [
      {:cowboy, "1.0.3"},
      {:earmark, "~> 0.1", only: :dev},
      {:ecto, "~> 1.0.2"},
      {:ex_doc, "~> 0.11", only: :dev},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:json, "~> 0.3.2"},
      {:pbkdf2, ">= 2.0.0", github: "basho/erlang-pbkdf2"},
      {:peon, ">= 2.0.0"},
      {:postgrex, ">= 0.7.0"},
      {:socket, "~> 0.3.1"},
      {:timex, ">= 0.13.1"},
      {:uuid, "~> 1.1.0"}
    ]
  end
end
