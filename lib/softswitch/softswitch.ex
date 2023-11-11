defmodule VoipstackClassicPanel.Softswitch do
  @moduledoc """
  A VirtualPBX Implementation
  """

  alias VoipstackClassicPanel.VirtualPBX

  defstruct [:handler, :handler_state, :vpbx]
  @type t :: %__MODULE__{}

  defmodule Handler do
    @moduledoc false

    @type t :: module()

    @type state :: any()
    @type event :: term()

    @callback handle_virtual_pbx_event(event(), state()) :: state()
  end

  @spec init(VirtualPBX.t(), Handler.t(), Handler.state()) :: t()
  def init(vpbx, handler, handler_state) do
    %__MODULE__{handler: handler, handler_state: handler_state, vpbx: vpbx}
  end

  def add_call(ctx, call_id, call_direction) do
    vpbx = VirtualPBX.add_call(ctx.vpbx, call_id, call_direction)
    ctx = %{ctx | vpbx: vpbx}

    event = %{call_id: call_id, direction: call_direction, caller: %{}, callee: %{}}
    notify(ctx, :new_call, event)

    ctx
  end

  def add_caller(ctx, call_id, caller_id, call_attrs) do
    vpbx = VirtualPBX.add_caller(ctx.vpbx, call_id, caller_id, call_attrs)
    ctx = %{ctx | vpbx: vpbx}

    notify(ctx, :update_call, VirtualPBX.get_call(vpbx, call_id))

    ctx
  rescue
    VirtualPBX.NotFoundCallError ->
      ctx
  end

  def add_callee(ctx, call_id, callee_id, call_attrs) do
    vpbx = VirtualPBX.add_callee(ctx.vpbx, call_id, callee_id, call_attrs)
    ctx = %{ctx | vpbx: vpbx}

    notify(ctx, :update_call, VirtualPBX.get_call(vpbx, call_id))

    ctx
  rescue
    VirtualPBX.NotFoundCallError ->
      ctx
  end

  defp notify(ctx, event_name, event) do
    ctx.handler.handle_virtual_pbx_event(
      {:virtual_pbx, ctx.vpbx.id, event_name, event},
      ctx.handler_state
    )
  end
end
