defmodule Noaa.TableFormatter do

  @moduledoc """
  Is formatting the results of the fetched data and the metadata into a table.
  """

  @doc """
  Prints the rows and the header to STDOUT
  """
  def print(rows, header) do
    columns   = extract_columns(rows, header)
    widths    = max_column_widths(columns, header)
    formatter = formatter_string(widths, " | ")
    print_header(header, formatter)
    print_horizontal_line({ "-", "-+-" }, widths)
    print_table(columns, formatter)
  end

  @doc """
  The header contains the header names of the data. The header filters the
  columns that should be extracted and displayed.

  ## Example
      iex> data   = [[ aaa: "a1", b: "b1", c: "c1"], 
      ...>           [ aaa: "a2", b: "b2", c: "c2222"]]
      iex> header =  [ :aaa, :c ]
      iex> Noaa.TableFormatter.extract_columns(data, header)
      [ [ "a1", "a2" ], [ "c1", "c2222" ] ]
  """
  def extract_columns(data, header) do
    for h <- header do
      for d <- data, do: to_string d[h]
    end
  end

  @doc """
  Determines based on the header columns and the row columns the maximum 
  column widths so the data fits into the columns.

  ## Example
      iex> columns = [[ "a1", "a2"], 
      ...>            [ "c1", "c2222"]]
      iex> header  = [ :aaa, :c ]
      iex> Noaa.TableFormatter.max_column_widths(columns, header)  
      [ 3, 5 ]
  """
  def max_column_widths(columns, header) do
    row_column_widths = columns
    |> Enum.map(&Enum.max_by(&1, fn(x) -> String.length(x) end)
    |> String.length)

    header_column_widths = header
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.length/1)

    List.zip([row_column_widths, header_column_widths])
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.max/1)
  end

  @doc """
  Creates a formatter string based on the column widths.

  ## Example
      iex> column_widths = [ 3, 5 ]
      iex> separator      = " | "
      iex> Noaa.TableFormatter.formatter_string(column_widths, separator)
      "~-3s | ~-5s~n"
  """
  def formatter_string(column_widths, separator) do
    (column_widths
    |> Enum.map(&("~-#{&1}s"))
    |> Enum.join(separator)) <> "~n"
  end

  @doc """
  Prints the extracted rows into a table format.
  """
  def print_table(data, formatter) do
    data
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.each(fn(row) -> :io.fwrite(formatter, row) end) 
  end

  @doc """
  Prints the table header.
  """
  def print_header(header, formatter) do
    :io.fwrite(formatter, header)
  end

  @doc """
  Prints a horizontal line between the header and the table body.
  """
  def print_horizontal_line({ line, separator }, widths) do
    widths
    |> Enum.map(&String.duplicate(line, &1))
    |> Enum.join(separator) 
    |> IO.puts
  end

end
