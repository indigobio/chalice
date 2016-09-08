defmodule Chalice.Util.OkTest do
  use ExUnit.Case
  import Chalice.Util.Ok

  test "ok: if ok, returns the value" do
    assert ok({:ok, 42}) == 42
  end

  test "ok: if not ok, raises an error" do
    assert_raise RuntimeError, "Expected {:ok, _} but got :oops", fn ->
      ok(:oops)
    end
  end
end
