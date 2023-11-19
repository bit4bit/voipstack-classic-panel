defmodule VoipstackClassicPanel.VirtualPBX.Times do
  @moduledoc false

  defstruct start_at: nil, answered_at: nil

  def new do
    %__MODULE__{}
  end
end

defmodule VoipstackClassicPanel.VirtualPBX.CallcenterQueue do
  @moduledoc false

  defstruct [:id, :name, :realm]

  def new(id, name, realm) do
    %__MODULE__{id: id, name: name, realm: realm}
  end
end

defmodule VoipstackClassicPanel.VirtualPBX.CallcenterAgent do
  @moduledoc false

  defstruct [:name, :state]

  def new(name) do
    %__MODULE__{name: name, state: :unknown}
  end
end

defmodule VoipstackClassicPanel.VirtualPBX.Channel do
  @moduledoc false

  defstruct [:id, :name, :number, :source]

  def new(id, name, number, source) do
    %__MODULE__{id: id, name: name, number: number, source: source}
  end
end

defmodule VoipstackClassicPanel.VirtualPBX.Call do
  @moduledoc false

  alias VoipstackClassicPanel.VirtualPBX.Channel
  alias VoipstackClassicPanel.VirtualPBX.Times

  defmodule UpdateStateError do
    defexception [:message]
  end

  defstruct [:id, :state, :times, caller: %{}, callee: %{}, tags: %{}]

  @type t :: %__MODULE__{
          state: :unknown | :ringing | :answered | :hangup
        }

  def new(id) do
    %__MODULE__{id: id, state: :unknown, times: Times.new()}
  end

  def add_callee(%__MODULE__{} = call, id, number, source) do
    %{call | callee: Channel.new(id, number, number, source)}
  end

  def add_caller(%__MODULE__{} = call, id, number, source) do
    %{call | caller: Channel.new(id, number, number, source)}
  end

  def update_call_state(%__MODULE__{state: :unknown} = call, :ringing) do
    %{call | state: :ringing}
  end

  def update_call_state(%__MODULE__{state: :unknown} = call, :answered) do
    %{call | state: :answered}
  end

  def update_call_state(%__MODULE__{state: :unknown} = call, :hangup) do
    %{call | state: :hangup}
  end

  def update_call_state(%__MODULE__{state: :ringing} = call, :answered) do
    %{call | state: :answered}
  end

  def update_call_state(%__MODULE__{state: :answered} = call, :hangup) do
    %{call | state: :hangup}
  end

  def update_call_state(%__MODULE__{state: :ringing} = call, :hangup) do
    %{call | state: :hangup}
  end

  def update_call_state(%__MODULE__{id: call_id, state: state}, new_state) do
    raise UpdateStateError,
      message: "can't update from state #{state} to #{new_state} for call #{call_id}"
  end

  # this is the new about this panel, every call can have
  # multiples tags that allows identify the purporse, the
  # most commons tags are from extension or did,
  # but we can used it for analytics.
  def add_tag(%__MODULE__{} = call, name, value) do
    %{call | tags: call.tags |> Map.put(name, value)}
  end
end
