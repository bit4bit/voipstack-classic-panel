defmodule VoipstackClassicPanel.VirtualPBXTest do
  @moduledoc false

  use ExUnit.Case
  alias VoipstackClassicPanel.VirtualPBX

  describe "VirtualPBX" do
    test "initials state of call" do
      vpbx =
        VirtualPBX.new("test")
        |> VirtualPBX.add_call("123456", :inbound)

      assert %{
               state: :unknown
             } = VirtualPBX.get_call(vpbx, "123456")
    end

    test "raises exception if not found call" do
      vpbx = VirtualPBX.new("test")

      assert_raise VirtualPBX.NotFoundCallError, fn ->
        VirtualPBX.get_call(vpbx, "not-exists")
      end
    end

    test "gets caller of call" do
      vpbx =
        VirtualPBX.new("test")
        |> VirtualPBX.add_call("123456", :inbound)
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
        VirtualPBX.new("test")
        |> VirtualPBX.add_call("123456", :inbound)
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
        VirtualPBX.new("test")
        |> VirtualPBX.add_call("123456", :inbound)
        |> VirtualPBX.add_tag("123456", "Name", "test")

      assert %{
               "Name" => "test"
             } = VirtualPBX.get_tags(vpbx, "123456")
    end

    test "removes call" do
      vpbx =
        VirtualPBX.new("test")
        |> VirtualPBX.add_call("123456", :inbound)
        |> VirtualPBX.remove_call("123456")

      assert_raise VirtualPBX.NotFoundCallError, fn ->
        VirtualPBX.get_call(vpbx, "123456")
      end
    end
  end

  # autotaggear en base a reglas
end
