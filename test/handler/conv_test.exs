defmodule ServyTest.ConvTest do
  use ExUnit.Case, async: true
  doctest Servy.Conv

  alias Servy.Conv

  describe "display_status/1" do
    @status_codes [
      {200, "OK"},
      {201, "Created"},
      {401, "Unauthorized"},
      {403, "Forbidden"},
      {404, "Not Found"},
      {500, "Internal Server Error"}
    ]

    for {code, phrase} <- @status_codes do
      test "returns #{phrase} for #{code}" do
        conv = %Conv{status: unquote(code)}
        assert Conv.display_status(conv) == "#{unquote(code)} #{unquote(phrase)}"
      end
    end

    test "returns status code only when reason phrase is unknown" do
      assert Conv.display_status(%Conv{status: 418}) == "Status unknown"
      assert Conv.display_status(%Conv{status: 999}) == "Status unknown"
    end
  end
end
