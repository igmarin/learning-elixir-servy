defmodule ServyTest.Api.BearControllerTest do
  use ExUnit.Case, async: true
  doctest Servy.Api.BearController

  alias Servy.Api.BearController
  alias Servy.Test.Fixtures

  test "index returns a list of bears as JSON" do
    conv = BearController.index(Fixtures.conv(path: "/api/bears"))
    assert conv.status == 200
    assert conv.resp_body =~ "Baloo"
    assert conv.resp_content_type == "application/json"
  end
end
