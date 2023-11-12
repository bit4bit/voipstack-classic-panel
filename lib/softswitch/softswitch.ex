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

  def add_call(ctx, call_id) do
    ctx =
      update_vpbx(ctx, fn vpbx ->
        VirtualPBX.add_call(vpbx, call_id)
      end)

    event = %{id: call_id, caller: %{}, callee: %{}}
    notify(ctx, :call_added, event)

    ctx
  end

  def remove_call(ctx, call_id) do
    call = VirtualPBX.get_call(ctx.vpbx, call_id)

    ctx =
      update_vpbx(ctx, fn vpbx ->
        VirtualPBX.remove_call(vpbx, call_id)
      end)

    notify(ctx, :call_removed, call)

    ctx
  rescue
    VirtualPBX.NotFoundCallError ->
      ctx
  end

  def add_caller(ctx, call_id, caller_id, call_attrs) do
    ctx =
      update_vpbx(ctx, fn vpbx ->
        VirtualPBX.add_caller(vpbx, call_id, caller_id, call_attrs)
      end)

    notify(ctx, :call_updated, VirtualPBX.get_call(ctx.vpbx, call_id))

    ctx
  rescue
    VirtualPBX.NotFoundCallError ->
      ctx
  end

  def add_callee(ctx, call_id, callee_id, call_attrs) do
    ctx =
      update_vpbx(ctx, fn vpbx ->
        VirtualPBX.add_callee(vpbx, call_id, callee_id, call_attrs)
      end)

    notify(ctx, :call_updated, VirtualPBX.get_call(ctx.vpbx, call_id))

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

  defp update_vpbx(ctx, updater) do
    vpbx = updater.(ctx.vpbx)
    %{ctx | vpbx: vpbx}
  end
end
