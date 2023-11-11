defmodule VoipstackClassicPanel.SoftswitchEventServer do
  @moduledoc false

  use GenServer

  alias VoipstackClassicPanel.VirtualPBX
  alias VoipstackClassicPanel.Softswitch

  defmodule SendHandler do
    @moduledoc false

    @behaviour Softswitch.Handler

    def handle_virtual_pbx_event(event, handler) when is_pid(handler) do
      send(handler, event)
      handler
    end
  end

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def start_listening(server) do
    GenServer.cast(server, {:add_listener, self()})
  end

  def stop_listening(server) do
    GenServer.cast(server, {:remove_listener, self()})
  end

  @impl true
  def init(:ok) do
    softswitch =
      VirtualPBX.new("softswitch")
      |> Softswitch.init(SendHandler, self())

    {:ok, %{softswitch: softswitch, listeners: %{}}}
  end

  @impl true
  def handle_cast({:add_listener, listener}, state) do
    listeners = Map.put(state.listeners, listener_key(listener), listener)

    send(listener, {:softswitch, "softswitch", :initial_state, %{calls: %{}}})

    {:noreply, %{state | listeners: listeners}}
  end

  def handle_cast({:remove_listener, listener}, state) do
    listeners = Map.delete(state.listeners, listener_key(listener))

    {:noreply, %{state | listeners: listeners}}
  end

  defp listener_key(listener) do
    Base.encode64(:erlang.term_to_binary(listener))
  end
end
