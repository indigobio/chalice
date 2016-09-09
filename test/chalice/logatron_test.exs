defmodule Chalice.LogatronTest do
  use ExUnit.Case

  import Chalice.Logatron

  test "format_json: returns the message in the form of logatron JSON" do
    ts = {{2016, 8, 4}, {1, 2, 3, 456}}
    md = [site: "cdc", request_id: "789"]
    console_config = Application.get_env(:logger, :console)
    console_config = Keyword.merge(console_config, [app_id: "foo_app"])
    Application.put_env(:logger, :console, console_config)
    x = format_json(:error, "oops", ts, md) |> Poison.decode!
    assert x["timestamp"] == "2016-08-04T01:02:03.456"
    assert x["app_id"] == "foo_app"
    assert x["pid"] == System.get_pid
    assert x["id"] == "789"
    assert x["site"] == "cdc"
    assert x["severity"] == "error"
    assert x["body"] == "oops"
  end

  test "format_json: adds request attributes, if present" do
    body = "method=GET path=/foo/bar duration=123.4"
    x = format_json(:error, body, {{2016, 8, 4}, {1, 2, 3, 456}}, []) |> Poison.decode!
    IO.puts("x = #{inspect(x)}")
    assert x["body"] == ""
    assert x["method"] == "GET"
    assert x["path"] == "/foo/bar"
    assert x["duration"] == 123
  end

  test "format_json: fails gracefully" do
    assert format_json(nil, nil, nil, nil) == "{}"
  end

  # The following tests correspond to commented out experimental code

  # test "clean_body accepts iolists" do
  #   assert clean_body(["hel", "lo"]) == "hello"
  # end

  # test "clean_body tolerates unmatching brackets" do
  #   assert clean_body("[104 | \"ello\"") == "[104 | \"ello\""
  # end

  # test "clean_body prettifies string representations of iolists" do
  #   str = "argument error :erlang.length([104 | [\"el\", \"lo\"]])"
  #   assert clean_body(str) == "argument error :erlang.length(\"hello\")"
  # end

  # test "clean_body works recursively" do
  #   str = "argument error :erlang.length([104 | [\"el\", \"lo\"]])"
  #   str2 = "argument error :erlang.length(#{inspect})"
  #   assert clean_body(str) == "argument error :erlang.length(\"hello\")"
  # end
end
