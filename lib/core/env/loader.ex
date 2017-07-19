defmodule Moongate.CoreLoader do
  alias Moongate.{
    CoreConfig,
    CoreBootstrap
  }

  @game_path CoreBootstrap.game_path()

  def load_config do
    case File.read("#{@game_path}/moongate.json") do
      {:ok, contents} ->
        game_config = Poison.decode!(contents, as: %CoreConfig{})

        %CoreConfig{}
        |> DeepMerge.deep_merge(game_config)
      _ ->
        %CoreConfig{}
    end
  end

  def load_data_files(filenames, root_path) do
    contents =
      filenames
      |> Enum.filter(&(Regex.match?(~r/.data.exs$/, &1)))
      |> Enum.map(fn filename ->
        path =
          filename
          |> String.split(root_path)
          |> tl
          |> Enum.join("")
        full_path = "#{root_path}/#{path}"

        "def game_data(\"#{path}\"), do: #{File.read!(full_path)}"
      end)

    Code.compile_string("""
      defmodule Moongate.CoreGameData do
        #{contents}
        def game_data(_), do: nil
      end
    """)

    filenames
  end

  defmacro __before_compile__(_env) do
    quote do
      Moongate.CoreUtility.ls_recursive(unquote(@game_path))
      |> Moongate.CoreLoader.load_data_files(unquote(@game_path))
    end
  end
end
