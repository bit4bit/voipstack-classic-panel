defmodule VoipstackClassicPanel.VirtualPBX do
  @moduledoc """
  Abstraction of softswitch
  """

  alias VoipstackClassicPanel.VirtualPBX.{Channel, Call}

  defstruct [:id, calls: %{}]
  @type t :: %__MODULE__{}

  defmodule NotFoundCallError do
    defexception [:message]
  end

  def new(softswitch_id) do
    %__MODULE__{id: softswitch_id}
  end

  def add_call(%__MODULE__{} = vpbx, call_id) do
    %{vpbx | calls: Map.put(vpbx.calls, call_id, Call.new(call_id))}
  end

  def get_call(%__MODULE__{} = vpbx, call_id) do
    get_call!(vpbx, call_id) |> Map.from_struct()
  end

  def add_caller(%__MODULE__{} = vpbx, call_id, caller_id, caller_attrs) do
    add_channel(vpbx, call_id, :caller, caller_id, caller_attrs)
  end

  def add_callee(%__MODULE__{} = vpbx, call_id, callee_id, callee_attrs) do
    add_channel(vpbx, call_id, :callee, callee_id, callee_attrs)
  end

  def get_caller(%__MODULE__{} = vpbx, call_id) do
    get_call!(vpbx, call_id).caller |> Map.from_struct()
  end

  def get_callee(%__MODULE__{} = vpbx, call_id) do
    get_call!(vpbx, call_id).callee |> Map.from_struct()
  end

  def remove_call(%__MODULE__{} = vpbx, call_id) do
    %{vpbx | calls: Map.delete(vpbx.calls, call_id)}
  end

  def add_tag(%__MODULE__{} = vpbx, call_id, name, value) do
    call = get_call!(vpbx, call_id)
    call = %{call | tags: Map.put(call.tags, name, value)}

    %{vpbx | calls: Map.put(vpbx.calls, call_id, call)}
  end

  def get_tags(%__MODULE__{} = vpbx, call_id) do
    get_call!(vpbx, call_id).tags
  end

  defp add_channel(vpbx, call_id, channel_key, channel_id, channel_attrs) do
    channel = Keyword.validate!(channel_attrs, [:name, :number, :source])
    call = get_call!(vpbx, call_id)

    call = %{
      call
      | channel_key => Channel.new(channel_id, channel[:name], channel[:number], channel[:source])
    }

    calls = Map.put(vpbx.calls, call_id, call)
    %{vpbx | calls: calls}
  end

  def get_call!(%__MODULE__{id: vpbx_id} = vpbx, call_id) do
    case Map.get(vpbx.calls, call_id) do
      nil ->
        raise NotFoundCallError,
          message: "not found call id #{call_id} for virtual pbx #{vpbx_id}"

      call ->
        call
    end
  end
end
