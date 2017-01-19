defmodule DfParse do

  defstruct [
    filesystem: nil,
    blocks: nil,
    blocks_type: nil,
    used: nil,
    available: nil,
    percent_capacity: nil,
    percent_iused: nil,
    mounted_on: nil,
  ]

  def df(path \\ ".") do
    case System.cmd("df", []) do
      {resp, 0} ->
        parse(resp)
      {_resp, code} ->
        {:error, {:status, code}}
    end
  end

  def to_lines(resp) when resp |> is_binary do
    resp
    |> String.split("\n")
    |> DfParse.Parse.filter_empties
  end

  def parse(resp) when resp |> is_binary do
    [ {:blocks_type, blocks_type} | lines ] =
      resp
      |> to_lines
      |> DfParse.Parse.filter_empties
      |> DfParse.Parse.parse_line
    lines
    |> Enum.map(fn line -> line |> Map.put(:blocks_type, blocks_type) end)
  end

end
