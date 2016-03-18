defmodule Moongate.Worlds do
  def get_world do
    if Mix.env() == :test do
      "test"
    else
      Application.get_env(:moongate, :world) || "default"
    end
  end
end
