defmodule ClientEvent do
  defstruct cast: nil, contents: nil, error: nil, origin: nil, to: nil
end

defmodule EventListener do
  defstruct auth: nil,
            id: nil
end