defmodule Test.Game do
  use Moongate.DSL, :game

  @doc "Called when the server is started."
  handle "start", ev do
    ev
    |> zone(Board, %{})
    |> zone({Board, "dsl_create_test"}, %{})
    |> zone({Board, "dsl_create_test_2"}, %{})
    |> zone({Board, "dsl_destroy_test"}, %{})
    |> zone({Board, "dsl_destroy_test_2"}, %{})
    |> zone({Board, "dsl_set_test"}, %{})
  end

  handle "begin", ev do
    ev
    |> join(Board)
  end

  handle "end", ev do
    ev
  end
end
