defmodule Moongate.Mixfile do
  use Mix.Project

  Code.compiler_options([ignore_module_conflict: true])

  # Prepare project using data from priv/project
  @bootstrap elem(Code.eval_file("priv/bootstrap.exs"), 0)

  def project do
    [
      app: :moongate,
      version: @bootstrap.version,
      codename: @bootstrap.codename,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixir: @bootstrap.elixir_version,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      description: @bootstrap.description,
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
        :poolboy,
        :redix,
        :redix_pubsub
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
      {:redix, ">= 0.0.0"},
      {:redix_pubsub, ">= 0.0.0"},
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

  @game_path Path.expand(@bootstrap.game_path)
  @base_paths ["lib", ".moongate/lib"]
  defp elixirc_paths(:test), do: @base_paths ++ fiber_entry_modules() ++ ["test/support"]
  defp elixirc_paths(_), do: @base_paths ++ fiber_entry_modules() ++ [@game_path]

  defp fiber_entry_modules do
    File.ls!("native")
    |> Enum.filter(&(File.exists?("native/#{&1}/#{&1}.ex")))
    |> Enum.map(&("native/#{&1}"))
  end

  @rustler_crate_defaults [
    cargo: :system,
    default_features: false,
    features: [],
    mode: :release
  ]
  defp rustler_crates do
    File.ls!("native")
    |> Enum.filter(fn filename ->
      with true <- File.exists?("native/#{filename}/src/lib.rs"),
           true <- File.exists?("native/#{filename}/Cargo.toml") do
        case File.read("native/#{filename}/Cargo.toml") do
          {:ok, contents} ->
            String.contains?(contents, "rustler = ")
          _ ->
            false
        end
      end
    end)
    |> Enum.map(fn filename ->
      {:"#{filename}", @rustler_crate_defaults ++ [path: "native/#{filename}"]}
    end)
  end
end
