defmodule VoipstackClassicPanelWeb.Panel do
  @moduledoc false

  use VoipstackClassicPanelWeb, :surface_live_view
  require Logger
  alias VoipstackClassicPanel.SoftswitchEventServer, as: Server
  alias VoipstackClassicPanelWeb.Components.Card

  @softswitch SoftswitchServer

  @impl true
  def mount(_, _, socket) do
    :ok = Server.start_listening(@softswitch)

    socket =
      assign(socket, :calls, %{})

    {:ok, socket}
  end

  @impl true
  def handle_info({:softswitch, _softswitch_id, :initial_state, state}, socket) do
    {:noreply, assign(socket, :calls, state.calls)}
  end

  @impl true
  def handle_info({:softswitch, _softswitch_id, :call_added, call}, socket) do
    calls = Map.put(socket.assigns[:calls], call.id, call)
    socket = assign(socket, :calls, calls)
    {:noreply, socket}
  end
end
