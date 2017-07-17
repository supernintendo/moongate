defmodule Moongate.CoreTerms do
  @terms ~w(
    __index__
    __origin_id__
    attach
    command
    echo
    event
    join
    leave
    origin
    ping
    index_members
    show_members
    show_morphs
    drop_members
    drop_morphs
  )
  def terms, do: @terms
end
