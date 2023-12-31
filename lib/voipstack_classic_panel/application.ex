defmodule VoipstackClassicPanel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {VoipstackClassicPanel.SoftswitchEventServer, name: SoftswitchServer},
      VoipstackClassicPanelWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:voipstack_classic_panel, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VoipstackClassicPanel.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: VoipstackClassicPanel.Finch},
      # Start a worker by calling: VoipstackClassicPanel.Worker.start_link(arg)
      # {VoipstackClassicPanel.Worker, arg},
      # Start to serve requests, typically the last entry
      VoipstackClassicPanelWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VoipstackClassicPanel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VoipstackClassicPanelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
