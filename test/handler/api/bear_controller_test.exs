defmodule ServyTest.Api.BearControllerTest do
  use ExUnit.Case, async: true
  doctest Servy.Api.BearController

  alias Servy.Api.BearController, as: ApiBearController
  alias Servy.Test.Fixtures

  test "index returns a list of bears as JSON" do
    conv = ApiBearController.index(Fixtures.conv(path: "/api/bears"))
    assert conv.status == 200
    assert conv.resp_body =~ "Baloo"
    assert conv.resp_content_type == "application/json"
  end

  test "POST /api/bears" do
    conv = Fixtures.conv(method: "POST", path: "/api/bears")
    params = %{name: "Breezly", type: "Polar"}

    result = ApiBearController.create(conv, params)

    assert result.status == 201
    assert result.resp_content_type == "application/json"
    assert result.resp_body == Jason.encode!(%{name: "Breezly", type: "Polar"})
  end
end
