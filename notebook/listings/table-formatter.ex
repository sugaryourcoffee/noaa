defmodule Noaa.TableFormatter do

  def print(rows, header) do
    columns   = extract_columns(rows, header)
    widths    = max_column_widths(columns, header)
    formatter = formatter_string(widths, " | ")
    print_header(header, formatter)
    print_horizontal_line({ "-", "-+-" }, widths)
    print_table(columns, formatter)
  end

  def extract_columns(data, header) do
    for h <- header do
      for d <- data, do: to_string d[h]
    end
  end

  def max_column_widths(rows, header) do
    row_column_widths = rows
    |> Enum.map(&Enum.max_by(&1, fn(x) -> String.length(x) end)
    |> String.length)

    header_column_widths = header
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.length/1)

    List.zip([row_column_widths, header_column_widths])
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.max/1)
  end

  def formatter_string(column_widths, separator) do
    (column_widths
    |> Enum.map(&("~-#{&1}s"))
    |> Enum.join(separator)) <> "~n"
  end

  def print_table(data, formatter) do
    data
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.each(fn(row) -> :io.fwrite(formatter, row) end) 
  end

  def print_header(header, formatter) do
    :io.fwrite(formatter, header)
  end

  def print_horizontal_line({ line, separator }, widths) do
    widths
    |> Enum.map(&String.duplicate(line, &1))
    |> Enum.join(separator) 
    |> IO.puts
  end

end
