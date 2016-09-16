defmodule Chalice.PreludeTest do
  use ExUnit.Case
  import Chalice.Prelude

  test "fst: returns the first element of a tuple" do
    assert fst({:a, :b}) == :a
    assert fst({:a, :b, :c}) == :a
    assert_raise ArgumentError, fn -> fst({}) end
  end

  test "snd: returns the second element of a tuple" do
    assert snd({:a, :b}) == :b
    assert snd({:a, :b, :c}) == :b
    assert_raise ArgumentError, fn -> snd({:a}) end
  end
end
