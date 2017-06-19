defmodule Moongate.CoreEvent do
  @moduledoc """
  Provides a data container for events passed to
  functions within game modules - this is the
  fundamental data structure that Moongate's
  DSL relies upon.
  """

  defstruct(
    arguments: {},
    assigns: %{},
    body: nil,
    fetched: nil,
    handler: nil,
    origin: nil,
    queue: [],
    ring: nil,
    selected: nil,
    step: 0,
    tag: nil,
    targets: [],
    rule: nil,
    void: false,
    zone: nil
  )
end
