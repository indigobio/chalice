defmodule Chalice.Util.Ok do
  def ok({:ok, val}), do: val
  def ok(x), do: raise "Expected {:ok, _} but got #{inspect(x)}"
end
