defmodule Moongate.PacketCompressor do
  alias Moongate.{
    Core,
    CoreETS,
    CoreTerms,
    CoreUtility
  }

  @blacklist [
    "Dispatcher",
    "Moongate"
  ]
  @collection_buffer 8
  @dsl_event_handler_regex ~r/handle_(.*)_event/

  def bootstrap do
    {:ok, modules} = :application.get_key(:moongate, :modules)

    bootstrap_core()
    bootstrap_modules(modules)
    bootstrap_game_terms(modules)
  end

  def bootstrap_collection(collection) do
    collection
    |> Enum.uniq()
    |> Enum.filter(&should_keep?/1)
    |> Enum.map(&define/1)
  end

  def bootstrap_core() do
    CoreTerms.terms()
    |> bootstrap_collection()
  end

  def bootstrap_game_terms(modules) do
    modules
    |> Enum.filter(&is_game_namespace?/1)
    |> Enum.flat_map(&determine_game_terms/1)
    |> bootstrap_collection()
  end

  def bootstrap_modules(modules) do
    modules
    |> Enum.filter(&should_define?/1)
    |> Enum.flat_map(&(Module.split(&1)))
    |> bootstrap_collection()
  end

  def buffer(collection) do
    collection
    |> Enum.with_index()
    |> Enum.group_by(&(rem(elem(&1, 1) + 1, @collection_buffer)), &(elem(&1, 0)))
    |> Enum.map(&(elem(&1, 1)))
  end

  def by_word, do: CoreETS.index(:packet)
  def by_token do
    by_word()
    |> Enum.map(fn {word, token} -> {token, word} end)
    |> Enum.into(%{})
  end

  def compress(word) when is_atom(word), do: compress(CoreUtility.atom_to_string(word))
  def compress(word) when is_bitstring(word) do
    case CoreETS.lookup({:packet, word}) do
      [{_word, token}] -> token
      _ -> word
    end
  end

  def define(word) when is_bitstring(word) do
    case Map.get(by_word(), word) do
      nil -> CoreETS.insert({:packet, word, next_index()})
      _ -> nil
    end
  end
  def define(_), do: nil

  def determine_game_terms(module) do
    module.__info__(:functions)
    |> Enum.map(fn {key, _arity} ->
      cond do
        Regex.match?(@dsl_event_handler_regex, "#{key}") ->
          Regex.replace(@dsl_event_handler_regex, "#{key}", fn _, result ->
            "#{result}"
          end)
        key == :__description__ ->
          module.__description__
          |> Enum.map(fn (entry) ->
            case entry do
              {{key, _type}, _default_value} -> "#{key}"
              _ -> nil
            end
          end)
        true ->
          nil
      end
    end)
    |> List.flatten
    |> Enum.filter(&(&1))
  end

  def expand(token) when is_integer(token) do
    case CoreETS.match_object({:packet, {:"$1", token}}) do
      [{word, _token}] -> word
      _ -> nil
    end
  end

  defp next_index do
    ((CoreETS.index(:packet)
    |> Enum.map(fn {_key, token} -> token end)
    |> Enum.sort
    |> List.last) || 0) + 1
  end

  defp should_define?(word) do
    is_game_namespace?(word)
  end

  defp is_game_namespace?(word) do
    String.contains?("#{word}", "#{Core.game}.")
  end

  defp should_keep?(word) do
    !Enum.member?(@blacklist, word)
  end
end
