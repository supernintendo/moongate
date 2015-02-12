defmodule AuthToken do
  defstruct email: nil,
            identity: UUID.uuid4(:hex),
            source: nil
end