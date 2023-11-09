defmodule VoipstackClassicPanel.VirtualPBXTest do
  @moduledoc false

  use ExUnit.Case
  alias VoipstackClassicPanel.VirtualPBX.{Call, Channel}

  test "representation of a call" do
    call =
      Call.new("123456")
      |> Call.add_caller("caller-1", "demo", "extension")
      |> Call.add_callee("callee-1", "test", "extension")
      |> Call.add_tag("Name", "demo")

    assert %Call{
             id: _,
             times: %{
               start_at: _,
               answered_at: _
             },
             state: :unknown,
             caller: %Channel{
               id: _,
               name: _,
               number: _,
               source: _
             },
             callee: %Channel{
               id: _,
               name: _,
               number: _,
               source: _
             },
             tags: %{
               "Name" => "demo"
             }
           } = call
  end
end
