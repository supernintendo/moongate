defmodule Area do
  defstruct default: false,
            entities: %{},
            generator: nil,
            id: nil,
            spec: nil,
            started: nil,
            tiles: [],
            timed_events: nil,
            process: nil,
            x: nil,
            y: nil
end

defmodule Entity do
  defstruct area_id: nil,
            last_move_time: nil,
            origin: nil,
            last_x: nil,
            last_y: nil,
            x: nil,
            y: nil
end