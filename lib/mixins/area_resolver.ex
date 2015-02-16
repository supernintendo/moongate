defmodule Mixins.AreaResolver do
  defmacro __using__(opts) do
    quote do
      # Return the correct params to use for a newly spawned area.
      defp mark_area_as_started(area, pid) do
        Map.merge(area, %{
          process: pid,
          spec: nil,
          started: true
        })
      end

      defp resolve_areas(areas_params) do
        result = Enum.map(areas_params, &spawn_area(&1))
        result
      end

      defp spawn_area(area_params) do
        if is_map(area_params) do
          id = UUID.uuid4(:hex)
          {module, _} = Code.eval_string(area_params["module"])
          area = %{
            default: area_params["default"],
            id: id,
            process: nil,
            spec: %{
              id: id,
              tiles: module.init(area_params["params"])
            },
            started: false,
            x: area_params["x"],
            y: area_params["y"],
          }
          area
        end
      end
    end
  end
end
