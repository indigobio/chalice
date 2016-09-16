defmodule Chalice.Prelude do
  def fst(x) when is_tuple(x) do
    elem(x, 0)
  end

  def snd(x) when is_tuple(x) do
    elem(x, 1)
  end
end
