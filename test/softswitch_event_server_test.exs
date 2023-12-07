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

    test "notifies new call" do
      softswitch = start_supervised!({SoftswitchEventServer, softswitch_id: "softswitch"})
      SoftswitchEventServer.start_listening(softswitch)

      SoftswitchEventServer.add_call(softswitch, "123456")

      assert_receive {:softswitch, "softswitch", :call_added, %{id: "123456"}}
    end

    test "notifies update caller" do
      softswitch = start_supervised!({SoftswitchEventServer, softswitch_id: "softswitch"})
      SoftswitchEventServer.start_listening(softswitch)
      SoftswitchEventServer.add_call(softswitch, "123456")

      :ok =
        SoftswitchEventServer.add_caller(softswitch, "123456", "1234567",
          name: "test",
          number: "test",
          source: "extension"
        )

      assert_receive {:softswitch, "softswitch", :call_updated,
                      %{
                        id: "123456",
                        caller: %{
                          id: "1234567",
                          name: "test",
                          number: "test",
                          source: "extension"
                        }
                      }}
    end
  end

  defp get_listeners(softswitch) do
    :sys.get_state(softswitch) |> Map.fetch!(:listeners)
  end
end
