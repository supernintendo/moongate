defmodule Area do
  defstruct default: false,
            entities: %{},
            generator: nil,
            id: nil,
            spec: nil,
            started: nil,
            timed_events: nil,
            process: nil,
            x: nil,
            y: nil
end