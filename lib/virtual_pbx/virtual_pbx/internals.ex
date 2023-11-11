defmodule VoipstackClassicPanel.VirtualPBX.Times do
  @moduledoc false

  defstruct start_at: nil, answered_at: nil

  def new do
    %__MODULE__{}
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

  defstruct [:id, :direction, :state, :times, caller: %{}, callee: %{}, tags: %{}]

  @type t :: %__MODULE__{
          direction: :inbound | :outbound,
          state: :unknown | :ringing | :answered | :hangup
        }

  def new(id, direction) when direction in [:inbound, :outbound] do
    %__MODULE__{id: id, direction: direction, state: :unknown, times: Times.new()}
  end

  def add_callee(%__MODULE__{} = call, id, number, source) do
    %{call | callee: Channel.new(id, number, number, source)}
  end

  def add_caller(%__MODULE__{} = call, id, number, source) do
    %{call | caller: Channel.new(id, number, number, source)}
  end

  # this is the new about this panel, every call can have
  # multiples tags that allows identify the purporse, the
  # most commons tags are from extension or did,
  # but we can used it for analytics.
  def add_tag(%__MODULE__{} = call, name, value) do
    %{call | tags: call.tags |> Map.put(name, value)}
  end
end
