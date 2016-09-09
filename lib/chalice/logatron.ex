defmodule Chalice.Logatron do
  @moduledoc """
  Writes log messages in logatron's format.

  Configure:

    config :logger, :console,
      app_id: :app_name_here,
      format: {Chalice.Logatron, :format_json},
      metadata: [:request_id, :site, ...]

  To make the site available, in phoenix applications:

    plug Chalice.Logatron.Site, "site_param_name_here"

  In other applications:

    Logger.metadata(site: "site_name")
  """
  alias Logger, as: L
  alias Logger.Formatter, as: LF

  @spec format_json(L.level, L.message, LF.time, Keyword.t) :: IO.chardata
  def format_json(level, msg_iodata, ts, md) do
    try do
      msg = IO.iodata_to_binary(msg_iodata)
      {body, request_attrs} = read_body_and_request_attrs(msg)
      base_attrs = read_base_attrs(level, body, ts, md)
      combined_attrs = Map.merge(base_attrs, request_attrs)
      Poison.encode!(combined_attrs) <> "\n"
    rescue
      e in _ ->
        sig = "format_json(#{inspect(level)}, #{inspect(msg_iodata)}, #{inspect(ts)}, #{inspect(md)})"
      IO.puts(:stderr, "Error during log formatting! : #{sig}\n  #{inspect(e)}")
      "{}"
    end
  end

  defp read_body_and_request_attrs(msg) do
    if String.contains?(msg, "method=") do
      request_attrs = %{
        method: attr(msg, "method"),
        path: attr(msg, "path"),
        format: attr(msg, "format"),
        controller: attr(msg, "controller"),
        action: attr(msg, "action"),
        params: attr(msg, "params"),
        status: attr(msg, "status"),
        duration: round(parse_float(attr(msg, "duration"))),
        state: attr(msg, "state")
      }
      {"", request_attrs}
    else
      {msg, %{}}
    end
  end

  defp read_base_attrs(level, msg, ts, md) do
    %{
      timestamp: format_timestamp(ts),
      app_id: app_id(),
      pid: System.get_pid,
      id: md[:request_id],
      site: md[:site] || "-",
      severity: level,
      body: msg
    }
  end

  defp app_id do
    Application.get_env(:logger, :console)[:app_id]
  end

  defp format_timestamp({{y,m,d},{h,mm,s,ms}}) do
    {{y,m,d},{h,mm,s}}
    |> Timex.to_naive_datetime
    |> Timex.add(Timex.Duration.from_milliseconds(ms))
    |> Timex.format!("{ISO:Extended}")
  end

  defp parse_float(str) do
    try do
      {v, ""} = Float.parse(str)
      v
    rescue _ -> str
    end
  end

  defp attr(msg, key) do
    pat = ~r/#{key}=(?<value>[^ ]*)/
    Regex.named_captures(pat, msg)["value"]
  end

  # The following is experimental code that applies IO.iodata_to_binary/1
  # to textual representations of iodata in the body.

  # # replace printed iolists with something more readable in exception messages
  # def clean_body(body) do
  #   #    IO.puts "clean_body(#{inspect(body)})"
  #   fix_iodata(IO.iodata_to_binary(body), 0, [], [])
  # end

  # defp fix_iodata(<<"[", rest::binary>>, depth, acc, bacc) do
  #   fix_iodata(rest, depth + 1, acc, ["[" | bacc])
  # end

  # defp fix_iodata(<<"]", rest::binary>>, depth, acc, bacc) do
  #   depth = depth - 1
  #   bacc = ["]" | bacc]
  #   if depth == 0 do
  #     fix_iodata(rest, depth, [binaryize(reverse(bacc)) | acc], [])
  #   else
  #     fix_iodata(rest, depth, acc, bacc)
  #   end
  # end

  # defp fix_iodata(<<x, rest::binary>>, 0, acc, bacc) do
  #   fix_iodata(rest, 0, [x | acc], bacc)
  # end

  # defp fix_iodata(<<x, rest::binary>>, depth, acc, bacc) do
  #   fix_iodata(rest, depth, acc, [x | bacc])
  # end

  # defp fix_iodata(<<>>, _, acc, bacc) do
  #   IO.iodata_to_binary(reverse(acc)) <> IO.iodata_to_binary(reverse(bacc))
  # end

  # defp binaryize(bacc) do
  #   str = IO.iodata_to_binary(bacc)
  #   try do
  #     {x, []} = Code.eval_string(str)
  #     x
  #     |> IO.iodata_to_binary
  #     |> clean_body
  #     |> inspect
    #   rescue
  #     _ ->
  #       str
  #   end
  # end


end
