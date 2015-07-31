defmodule Macros.Scopes do
  defmacro __using__(_) do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)
    world = config["world"] || "default"

    if File.exists?("worlds/#{world}/scopes/start.ex"), do: Code.eval_file("worlds/#{world}/scopes/start.ex")
    if File.exists?("worlds/#{world}/scopes/events.ex"), do: Code.eval_file("worlds/#{world}/scopes/events.ex")

    unless Code.ensure_compiled?(Scopes.Start) do
      quote do
        defmodule Start do
          def on_load do
          end
        end
      end
    end

    unless Code.ensure_compiled?(Scopes.Events) do
      quote do
        defmodule Events do
          def take(event, state) do
            state
          end
        end
      end
    end
  end
end
