defmodule VoipstackClassicPanel.VirtualPBXTest do
  @moduledoc false

  use ExUnit.Case
  alias VoipstackClassicPanel.VirtualPBX

  describe "VirtualPBX" do
    test "initials state of call" do
      vpbx =
        a_vpbx()
        |> add_a_call()

      assert %{
               state: :unknown
             } = VirtualPBX.get_call(vpbx, "123456")
    end

    test "raises exception if not found call" do
      assert_raise VirtualPBX.NotFoundCallError, fn ->
        VirtualPBX.get_call(a_vpbx(), "not-exists")
      end
    end

    test "gets caller of call" do
      vpbx =
        a_vpbx()
        |> add_a_call()
        |> VirtualPBX.add_caller("123456", "1234567",
          name: "test",
          number: "test",
          source: "extension"
        )

      assert %{
               id: "1234567",
               name: "test",
               number: "test",
               source: "extension"
             } = VirtualPBX.get_caller(vpbx, "123456")
    end

    test "gets callee of call" do
      vpbx =
        a_vpbx()
        |> add_a_call()
        |> VirtualPBX.add_callee("123456", "1234567",
          name: "test",
          number: "test",
          source: "extension"
        )

      assert %{
               id: "1234567",
               name: "test",
               number: "test",
               source: "extension"
             } = VirtualPBX.get_callee(vpbx, "123456")
    end

    test "adds tag to call" do
      vpbx =
        a_vpbx()
        |> add_a_call()
        |> VirtualPBX.add_tag("123456", "Name", "test")

      assert %{
               "Name" => "test"
             } = VirtualPBX.get_tags(vpbx, "123456")
    end

    test "removes call" do
      vpbx =
        a_vpbx()
        |> add_a_call()
        |> VirtualPBX.remove_call("123456")

      assert_raise VirtualPBX.NotFoundCallError, fn ->
        VirtualPBX.get_call(vpbx, "123456")
      end
    end
  end

  describe "callcenter" do
    test "adds callcenter queue" do
      vpbx =
        a_vpbx()
        |> VirtualPBX.add_callcenter_queue("demo", "test")

      assert %{
               name: "demo",
               realm: "test"
             } = get_callcenter_queue(vpbx, "demo", "test")
    end

    test "lists callcenter queues" do
      vpbx =
        a_vpbx()
        |> VirtualPBX.add_callcenter_queue("demo", "test")
        |> VirtualPBX.add_callcenter_queue("demo", "notest")

      assert [
               %{
                 name: "demo",
                 realm: "test"
               }
             ] = VirtualPBX.list_callcenter_queues(vpbx, "test")
    end

    test "lists callcenter agents" do
      vpbx =
        a_vpbx()
        |> VirtualPBX.add_callcenter_queue("demo", "test")
        |> VirtualPBX.add_callcenter_agent("demo", "test", "agent1")

      assert [
               %{
                 name: "agent1",
                 state: :unknown
               }
             ] = VirtualPBX.list_callcenter_agents(vpbx, "demo", "test")
    end
  end

  describe "call flow states" do
    test "from unknown to ringing" do
      vpbx =
        a_vpbx()
        |> add_a_call("1234567")
        |> VirtualPBX.update_call_state("1234567", :ringing)

      assert %{
               state: :ringing
             } = get_call(vpbx, "1234567")
    end

    test "from unknown to answered (not ringing)" do
      vpbx =
        a_vpbx()
        |> add_a_call("1234567")
        |> VirtualPBX.update_call_state("1234567", :answered)

      assert %{
               state: :answered
             } = get_call(vpbx, "1234567")
    end

    test "from unknown to hangup (not answered)" do
      vpbx =
        a_vpbx()
        |> add_a_call("1234567")
        |> VirtualPBX.update_call_state("1234567", :hangup)

      assert %{
               state: :hangup
             } = get_call(vpbx, "1234567")
    end

    test "from ringing to answer" do
      vpbx =
        a_vpbx()
        |> add_a_call("1234567")
        |> VirtualPBX.update_call_state("1234567", :ringing)
        |> VirtualPBX.update_call_state("1234567", :answered)

      assert %{
               state: :answered
             } = get_call(vpbx, "1234567")
    end

    test "from answered to hangup" do
      vpbx =
        a_vpbx()
        |> add_a_call("1234567")
        |> VirtualPBX.update_call_state("1234567", :ringing)
        |> VirtualPBX.update_call_state("1234567", :answered)
        |> VirtualPBX.update_call_state("1234567", :hangup)

      assert %{
               state: :hangup
             } = get_call(vpbx, "1234567")
    end

    test "from ringing to hangup" do
      vpbx =
        a_vpbx()
        |> add_a_call("1234567")
        |> VirtualPBX.update_call_state("1234567", :ringing)
        |> VirtualPBX.update_call_state("1234567", :hangup)

      assert %{
               state: :hangup
             } = get_call(vpbx, "1234567")
    end

    test "raises from answer to ringing" do
      vpbx =
        a_vpbx()
        |> add_a_call("1234567")
        |> VirtualPBX.update_call_state("1234567", :ringing)
        |> VirtualPBX.update_call_state("1234567", :answered)

      assert_raise VirtualPBX.Call.UpdateStateError, fn ->
        VirtualPBX.update_call_state(vpbx, "1234567", :ringing)
      end
    end
  end

  defp a_vpbx() do
    VirtualPBX.new("test")
  end

  defp add_a_call(vpbx, call_id \\ "123456") do
    VirtualPBX.add_call(vpbx, call_id)
  end

  defp get_call(vpbx, call_id) do
    VirtualPBX.get_call(vpbx, call_id)
  end

  defp get_callcenter_queue(vpbx, queue, realm) do
    VirtualPBX.get_callcenter_queue(vpbx, queue, realm)
  end

  # autotaggear en base a reglas
end
