defmodule TableFormatterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Noaa.TableFormatter, as: TF

  def test_data do
    [ [ c11111: "c1",  c2: "c12", c3: "c1345", c4: "c1456", c5: "c15678"  ],
      [ c11111: "c2",  c2: "c22", c3: "c234",  c4: "c2456", c5: "c25678"  ],
      [ c11111: "c3",  c2: "c32", c3: "c334",  c4: "c3456", c5: "c356789" ],
      [ c11111: 3.56,  c2: "c42", c3: "c434",  c4: "c4456", c5: "c45678"  ],
      [ c11111: "c56", c2: "c52", c3: "c534",  c4: "c5456", c5: "c55678"  ] ]
  end
  
  def test_headers, do: [ :c11111, :c3, :c5 ]

  test "Extract columns" do
    columns = TF.extract_columns(test_data, test_headers)
    assert List.first(columns) == [ "c1", "c2", "c3", "3.56", "c56" ]
    assert List.last(columns)  == [ "c15678", "c25678", "c356789", "c45678", 
                                    "c55678" ]
  end

  test "column width" do
    widths = TF.max_column_widths(TF.extract_columns(test_data, test_headers),
                                  test_headers)
    assert widths == [6, 5, 7]
  end

  test "formatter string" do
    assert TF.formatter_string([6, 5, 7], "|") == "~-6s|~-5s|~-7s~n"
  end

  test "print table header" do
    result = capture_io fn -> 
      TF.print_header(test_headers, TF.formatter_string([6, 5, 7], " | "))
      TF.print_horizontal_line({ "-", "-+-" }, [6, 5, 7])
    end

    assert result == """
    c11111 | c3    | c5     
    -------+-------+--------
    """
  end

  test "formatted table" do
    columns = TF.extract_columns(test_data, test_headers)
    formatter = TF.formatter_string([6, 5, 7], " | ")
    result = capture_io fn ->
      TF.print_header(test_headers, formatter)
      TF.print_horizontal_line({ "-", "-+-" }, [6, 5, 7])
      TF.print_table(columns, formatter)
    end

    assert result == """
    c11111 | c3    | c5     
    -------+-------+--------
    c1     | c1345 | c15678 
    c2     | c234  | c25678 
    c3     | c334  | c356789
    3.56   | c434  | c45678 
    c56    | c534  | c55678 
    """
  end

end
