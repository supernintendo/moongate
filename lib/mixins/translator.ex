defmodule Mixins.Translator do
  defmacro __using__(opts) do
    quote do
      defp link(params, name) do
        link(params, "", name)
      end

      defp link(params, namespace, name) do
        if is_atom(namespace), do: namespace = Atom.to_string(namespace)
        if is_atom(name), do: name = Atom.to_string(name)
        if namespace != "", do: namespace = namespace <> "_"

        GenServer.start_link(__MODULE__, params, [name: String.to_atom(namespace <> name)])
      end
    end
  end
end