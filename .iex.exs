Application.put_env(:elixir, :ansi_enabled, true)
IEx.configure(
  default_prompt: "> ",
  history_size: -1,
  colors: [
    eval_result: [:blue, :bright]
  ]
)
import Moongate.Core.Iex
