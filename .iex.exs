Application.put_env(:elixir, :ansi_enabled, true)
IEx.configure(
  default_prompt: "moongate : ",
  history_size: -1,
  colors: [
    eval_result: [:cyan, :bright]
  ]
)
import Moongate.OS.Iex
