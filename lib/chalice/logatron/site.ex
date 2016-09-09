defmodule Chalice.Logatron.Site do
  @moduledoc """
  A plug that makes the site name available to the logger
  """

  def init(param_name), do: param_name

  def call(conn, param_name) do
    Logger.metadata(site: conn.params[param_name])
    conn
  end
end
