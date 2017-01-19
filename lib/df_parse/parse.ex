defmodule DfParse.Parse do

  def filter_empties(lines) do
    Enum.filter(lines, fn
      ""  -> false
      " " -> false
      nil -> false
      _   -> true
    end)
  end

  def parse_int(int) when int |> is_binary do
    case Float.parse(int) do
      {num,  ""} -> round(num)
      {num, "%"} -> round(num)
      {num, "k"} -> round(num * 1.0e3)
      {num, "K"} -> round(num * 1.0e3)
      {num, "M"} -> round(num * 1.0e6)
      {num, "G"} -> round(num * 1.0e9)
      {num, "T"} -> round(num * 1.0e12)
      {num, "P"} -> round(num * 1.0e15)
      :error -> raise "Invalid int - cannot parse #{inspect int}"
    end
  end

  def parse_line(lines) when is_list(lines) do
    lines
    |> Enum.map(fn line -> parse_line(:line, line) end)
  end
  def parse_line(:line, line) when line |> is_binary do
    splitted =
      line
      |> String.split
      |> filter_empties
    parse_line(:line, splitted)
  end
  def parse_line(:line, ["Filesystem", "512-blocks" | _ ]) do
    {:blocks_type, 512}
  end
  def parse_line(:line, ["Filesystem", "1K-blocks" | _ ]) do
    {:blocks_type, 1024}
  end
  def parse_line(:line, [fs, blocks, used, available, percent_iused, mounted_on]) do
    used = parse_int(used)
    available = parse_int(available)
    capacity = round( (used / (used + available)) * 100)
    %DfParse{
      filesystem:       fs,
      blocks:           parse_int(blocks),
      used:             used,
      available:        available,
      percent_capacity: capacity,
      percent_iused:    parse_int(percent_iused),
      mounted_on:       mounted_on,
    }
  end

  def parse_line(:line, ["map", name | rest ]) do
    parse_line(:line, [ "map " <> name | rest ])
  end
  def parse_line(:line, [fs, blocks, used, available, capacity, _iused, _ifree, percent_iused, mounted_on]) do
    %DfParse{
      filesystem:       fs,
      blocks:           parse_int(blocks),
      used:             parse_int(used),
      available:        parse_int(available),
      percent_capacity: parse_int(capacity),
      percent_iused:    parse_int(percent_iused),
      mounted_on:       mounted_on,
    }
  end

end
