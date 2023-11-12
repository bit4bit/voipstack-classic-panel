defmodule VoipstackClassicPanel.SoftswitchTest do
  @moduledoc false

  use ExUnit.Case

  alias VoipstackClassicPanel.Softswitch
  alias VoipstackClassicPanel.VirtualPBX

  defmodule SendHandler do
    def handle_virtual_pbx_event(event, state) do
      send(state, event)
      state
    end
  end

  describe "Softswitch.EventHandler" do
    setup do
      handler =
        VirtualPBX.new("test")
        |> Softswitch.init(SendHandler, self())

      %{handler: handler}
    end

    test "notify new call", %{handler: handler} do
      Softswitch.add_call(handler, "123456")

      assert_receive {:virtual_pbx, "test", :call_added,
                      %{id: "123456", caller: %{}, callee: %{}}}
    end

    test "notifies caller of call", %{handler: handler} do
      handler
      |> Softswitch.add_call("123456")
      |> Softswitch.add_caller("123456", "1234567",
        name: "test",
        number: "test",
        source: "extension"
      )

      assert_received {:virtual_pbx, "test", :call_updated,
                       %{id: "123456", caller: %{id: "1234567"}, callee: %{}}}
    end

    test "notifies callee of call", %{handler: handler} do
      handler
      |> Softswitch.add_call("123456")
      |> Softswitch.add_callee("123456", "1234567",
        name: "test",
        number: "test",
        source: "extension"
      )

      assert_received {:virtual_pbx, "test", :call_updated,
                       %{id: "123456", caller: %{}, callee: %{id: "1234567"}}}
    end

    test "does not notify caller on invalid call", %{handler: handler} do
      handler
      |> Softswitch.add_caller("123456abcg", "1234567",
        name: "test",
        number: "test",
        source: "extension"
      )

      refute_received {:virtual_pbx, "test", :call_updated, _}
    end

    test "does not notify callee on invalid call", %{handler: handler} do
      handler
      |> Softswitch.add_callee("123456abcg", "1234567",
        name: "test",
        number: "test",
        source: "extension"
      )

      refute_received {:virtual_pbx, "test", :call_updated, _}
    end

    test "notifies remove call", %{handler: handler} do
      handler
      |> Softswitch.add_call("123456")
      |> Softswitch.remove_call("123456")

      assert_received {:virtual_pbx, "test", :call_removed, %{id: "123456"}}
    end

    test "doesn't notify remove call on invalid call", %{handler: handler} do
      handler
      |> Softswitch.remove_call("123456")

      refute_received {:virtual_pbx, "test", :call_removed, %{id: "123456"}}
    end
  end
end
