defmodule MoongateElectronClient do
  alias Moongate.{
    Core,
    CoreFirmware
  }

  @game_path CoreFirmware.game_path()
  @client_path Path.expand("priv/clients/electron/js")
  @launch_command "electron #{@client_path} #{Path.expand(@game_path)}/moongate.json"
  def launch_command(_), do: @launch_command

  @screen_warning "#{inspect __MODULE__}: Fullscreen is disabled when launching Electron from screen"
  @tmux_warning "#{inspect __MODULE__}: Fullscreen is disabled when launching Electron from tmux"

  def before_init do
    if File.exists?("#{@client_path}/dist") do
      :ok
    else
      raise "#{__MODULE__}: Client not compiled. You must run `npm install && npm run build` within #{@client_path}"
    end
  end

  def after_init, do: alert_terminal_limitations()

  def handle(_message), do: :ok

  defp alert_terminal_limitations do
    cond do
      System.get_env("TERM") == "screen" ->
        Core.log({:warning, @screen_warning})
      !is_nil(System.get_env("TMUX")) ->
        Core.log({:warning, @tmux_warning})
      true ->
        nil
    end
  end
end
