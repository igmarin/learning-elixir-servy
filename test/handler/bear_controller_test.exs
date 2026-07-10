defmodule ServyTest.BearControllerTest do
  use ExUnit.Case, async: true
  doctest Servy.BearController

  alias Servy.BearController
  alias Servy.Test.Fixtures

  describe "index/1" do
    test "returns 200 and lists bears from the template" do
      result = BearController.index(Fixtures.conv(path: "/bears"))

      assert result.status == 200
      assert result.resp_body =~ "<ul>"
      assert result.resp_body =~ "Bear 1: Baloo"
      assert result.resp_body =~ "Bear 2: Boo"
    end
  end

  describe "show/2" do
    test "returns 200 and the bear details for a known id" do
      result = BearController.show(Fixtures.conv(path: "/bears/1"), %{"id" => "1"})

      assert result.status == 200
      assert result.resp_body =~ "Bear 1: Baloo"
      assert result.resp_body =~ "hibernating? true"
    end
  end

  describe "delete/2" do
    test "always returns 403 Forbidden" do
      result =
        BearController.delete(Fixtures.conv(method: "DELETE", path: "/bears/1"), %{"id" => "1"})

      assert result.status == 403
      assert result.resp_body == "Delete a bear is Forbidden"
    end
  end
end
