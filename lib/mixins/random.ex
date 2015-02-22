defmodule Mixins.Random do
  defmacro __using__(_) do
    quote do
      defp random do
        :random.uniform
      end

      defp random_of(max) do
        round(Float.ceil(max * random))
      end

      defp seed_random do
        << a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
        :random.seed(a, b, c)
      end
    end
  end
end
