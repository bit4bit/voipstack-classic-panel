defmodule VoipstackClassicPanel.SoftswitchEventServerTest do
  @moduledoc false

  use ExUnit.Case

  alias VoipstackClassicPanel.SoftswitchEventServer

  test "start_link/1" do
    start_supervised!(SoftswitchEventServer)
  end

  describe "listeners" do
    test "start_listening/1" do
      softswitch = start_supervised!(SoftswitchEventServer)

      SoftswitchEventServer.start_listening(softswitch)

      assert %{} != get_listeners(softswitch)
    end

    test "stop_listening/1" do
      softswitch = start_supervised!(SoftswitchEventServer)
      SoftswitchEventServer.start_listening(softswitch)

      SoftswitchEventServer.stop_listening(softswitch)

      assert %{} == get_listeners(softswitch)
    end
  end

  describe "events" do
    test "notifies initial softswitch state" do
      softswitch = start_supervised!(SoftswitchEventServer)

      SoftswitchEventServer.start_listening(softswitch)

      assert_receive {:softswitch, "softswitch", :initial_state, %{calls: %{}}}
    end
  end

  defp get_listeners(softswitch) do
    :sys.get_state(softswitch) |> Map.fetch!(:listeners)
  end
end
