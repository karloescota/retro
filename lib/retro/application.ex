defmodule Retro.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # Retro.Repo,
      # Start the Telemetry supervisor
      RetroWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Retro.PubSub},
      # Start the Endpoint (http/https)
      RetroWeb.Endpoint,
      # Start a worker by calling: Retro.Worker.start_link(arg)
      # {Retro.Worker, arg}
      {Registry, keys: :unique, name: Retro.BoardRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Retro.BoardSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Retro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RetroWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
