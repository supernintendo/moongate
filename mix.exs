defmodule Moongate.Mixfile do
  use Mix.Project

  Code.compiler_options([ignore_module_conflict: true])

  # Prepare project using data from priv/project
  @firmware elem(Code.eval_file("priv/firmware.exs"), 0)

  def project do
    [
      app: :moongate,
      version: @firmware.version,
      codename: @firmware.codename,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixir: @firmware.elixir_version,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      description: @firmware.description,
      default_task: "run",
      compilers: [:rustler] ++ Mix.compilers(),
      rustler_crates: rustler_crates()
    ]
  end

  def application do
    [
      applications: [
        :bunt,
        :cowboy,
        :deep_merge,
        :eon,
        :inflex,
        :logger,
        :manifold,
        :poison,
        :poolboy
      ],
      mod: {Moongate, []}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.9", only: :dev},
      {:benchee_html, "~> 0.3", only: :dev},
      {:bunt, "~> 0.2.0"},
      {:cowboy, github: "ninenines/cowboy", tag: "2.0.0-pre.3"},
      {:deep_merge, "~> 0.1.1"},
      {:eon, "~> 4.1.0"},
      {:exmorph, "~> 1.1.1"},
      {:fastglobal, "1.0.0"},
      {:inflex, "~> 1.8.1"},
      {:hashids, "~> 2.0"},
      {:manifold, "~> 1.0"},
      {:mock, "~> 0.2.0", only: :test},
      {:poison, "~> 3.0"},
      {:poolboy, "~> 1.5.1"},
      {:rustler, github: "hansihe/rustler", sparse: "rustler_mix"}
    ]
  end

  @game_path Path.expand(@firmware.game_path)
  @base_paths ["lib", ".moongate/lib"]
  defp elixirc_paths(:test), do: @base_paths ++ ["test/support"]
  defp elixirc_paths(_), do: @base_paths ++ [@game_path]

  @rustler_crate_defaults [
    cargo: :system,
    default_features: false,
    features: [],
    mode: :release
  ]
  defp rustler_crates do
    @firmware.rust_libs
    |> Enum.filter(fn {_lib_name, lib_opts} -> is_map(lib_opts) end)
    |> Enum.map(fn {lib_name, %{} = lib_opts} ->
      {:"mg_#{lib_name}",
        (Map.get(lib_opts, [:crate_opts], @rustler_crate_defaults))
        ++ [path: "native/mg_#{lib_name}"]}
    end)
  end
end
