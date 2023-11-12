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

  def a_vpbx() do
    VirtualPBX.new("test")
  end

  def add_a_call(vpbx, call_id \\ "123456") do
    VirtualPBX.add_call(vpbx, call_id)
  end

  # autotaggear en base a reglas
end
