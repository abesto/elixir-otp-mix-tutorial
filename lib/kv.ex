defmodule KV do
  @moduledoc "Simple key-value store application"
  use Application

  def start(_type, _args) do
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
