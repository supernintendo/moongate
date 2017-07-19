defmodule GenRustlerBridge do
  require Logger

  @nif_pattern ~r/rustler_export_nifs![ \t]*+\{.*?([^}]+)/

  def call do
    IO.puts ("#{inspect __MODULE__}: Regenerating Rust bindings")
    if File.exists?(".moongate/lib/native") do
      File.rm_rf(".moongate/lib/native")
    end
    File.mkdir_p(".moongate/lib/native")
    File.ls!("native")
    |> Enum.map(fn crate_name ->
      case File.read("native/#{crate_name}/src/lib.rs") do
        {:ok, contents} -> {crate_name, contents}
        _ -> nil
      end
    end)
    |> Enum.filter(&(&1))
    |> Enum.filter(fn {_crate_name, contents} ->
      Regex.match?(@nif_pattern, contents)
    end)
    |> Enum.map(&gen_elixir_module/1)
  end

  defp gen_elixir_module({crate_name, source_code}) do
    [elixir_module | exports] =
      Regex.run(@nif_pattern, source_code)
      |> List.last()
      |> String.replace("[", "")
      |> String.replace("(", "")
      |> String.replace("\"", "")
      |> String.replace("\n", "")
      |> String.replace(" ", "")
      |> String.split(~r/(,)[^,]*$/)
      |> List.first()
      |> String.split(",")
    export_defs =
      exports
      |> Enum.chunk(3)
      |> Enum.map(fn [func_name, func_arity, _] ->
        args =
          (0..String.to_integer(func_arity) - 1)
          |> Enum.map(fn n ->
            "_arg#{n + 1}"
          end)
          |> Enum.join(", ")

        "  def #{func_name}(#{args}), do: exit(:nif_not_loaded)"
      end)
    module_name = String.replace(elixir_module, "Elixir.", "")

    File.write!(
      ".moongate/lib/native/#{crate_name}.ex",
      template(module_name, crate_name, export_defs)
    )
  end

  defp template(name, crate_name, export_defs) do
    if length(export_defs) == 0 do
      Logger.warn ~s(
native/#{crate_name}/src/lib.rs: No exports defined in `rustler_export_nifs!`
This module will not be accessible from Elixir.
`)
      |> String.trim()
    end
    ~s(
defmodule #{name} do
  use Rustler,
    otp_app: :moongate,
    crate: :#{crate_name}
#{Enum.join(export_defs, "\n")}
end)
    |> String.trim()
  end
end

GenRustlerBridge.call()
