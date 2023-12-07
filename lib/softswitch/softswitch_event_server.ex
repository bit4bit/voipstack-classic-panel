defmodule VoipstackClassicPanel.SoftswitchEventServer do
  @moduledoc false

  use GenServer
  require Logger
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
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def start_listening(server) do
    Logger.info(inspect(server))

    GenServer.cast(server, {:add_listener, self()})
  end

  def stop_listening(server) do
    GenServer.cast(server, {:remove_listener, self()})
  end

  def add_call(server, call_id) do
    GenServer.cast(server, {:add_call, call_id})
  end

  def add_caller(server, call_id, caller_id, call_attrs) when is_list(call_attrs) do
    case Keyword.validate(call_attrs, [:name, :number, :source]) do
      {:error, fields} ->
        {:error, fields}

      {:ok, call_attrs} ->
        GenServer.call(server, {:add_caller, call_id, caller_id, call_attrs})
    end
  end

  @impl true
  def init(opts) do
    id = Keyword.get(opts, :softswitch_id, "softswitch")

    softswitch =
      VirtualPBX.new(id)
      |> Softswitch.init(SendHandler, self())

    {:ok, %{id: id, softswitch: softswitch, listeners: %{}}}
  end

  @impl true
  def handle_call({:add_caller, call_id, caller_id, call_attrs}, _from, state) do
    softswitch = Softswitch.add_caller(state.softswitch, call_id, caller_id, call_attrs)

    {:reply, :ok, %{state | softswitch: softswitch}}
  end

  @impl true
  def handle_cast({:add_call, call_id}, state) do
    softswitch = Softswitch.add_call(state.softswitch, call_id)

    {:noreply, %{state | softswitch: softswitch}}
  end

  def handle_cast({:add_listener, listener}, state) do
    listeners = Map.put(state.listeners, listener_key(listener), listener)

    send(listener, {:softswitch, state.id, :initial_state, %{calls: %{}}})

    {:noreply, %{state | listeners: listeners}}
  end

  def handle_cast({:remove_listener, listener}, state) do
    listeners = Map.delete(state.listeners, listener_key(listener))

    {:noreply, %{state | listeners: listeners}}
  end

  @impl true
  def handle_info({:virtual_pbx, _, :call_added, event}, state) do
    notify(state.listeners, {:softswitch, state.id, :call_added, event})

    {:noreply, state}
  end

  def handle_info({:virtual_pbx, _, :call_updated, event}, state) do
    notify(state.listeners, {:softswitch, state.id, :call_updated, event})

    {:noreply, state}
  end

  defp listener_key(listener) do
    Base.encode64(:erlang.term_to_binary(listener))
  end

  defp notify(listeners, event) when is_map(listeners) do
    for {_, listener} <- listeners do
      send(listener, event)
    end
  end
end
