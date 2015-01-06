defmodule CliProcessTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Noaa.CLI, only: [ process: 1 ]

  test "process :datasets to fetch datasets" do
    result = capture_io fn -> process({:datasets, 1}) end

    assert result == """
    #{IO.ANSI.format(["\n", :blue, :bright, "Datasets"], true)}
    name             | id     | mindate    | maxdate    | datacoverage
    -----------------+--------+------------+------------+-------------
    Annual Summaries | ANNUAL | 1831-02-01 | 2014-07-01 | 1           
    #{IO.ANSI.format(["\n", :blue, :bright, "Metadata"], true)}
    limit | count | offset
    ------+-------+-------
    1     | 11    | 1     
    """
  end

  test "process :locations to fetch locations" do
    result = capture_io fn -> process({:locations, 1}) end

    assert result == """
    #{IO.ANSI.format(["\n", :blue, :bright, "Locations"], true)}
    name      | id            | mindate    | maxdate    | datacoverage
    ----------+---------------+------------+------------+-------------
    Ajman, AE | CITY:AE000002 | 1944-03-01 | 2014-12-30 | 0.6859      
    #{IO.ANSI.format(["\n", :blue, :bright, "Metadata"], true)}
    limit | count | offset
    ------+-------+-------
    1     | 38497 | 1     
    """
  end

  test "process :locations to search for a city" do
    result = process({:locations, "Munich"})

    assert result == "Munich location"
  end

  test "process :data to fetch data for a specified city" do
    result = capture_io fn -> 
                          process({:data, 
                                   [dataset: "GHCND", 
                                    location: "CITY:GM000019", 
                                    from: "2014-10-01", 
                                    to: "2014-10-01"]})
                        end

    assert result == """
    #{IO.ANSI.format(["\n", :blue, :bright, "Weather Data"], true)}
    datatype | value | station           | attributes | date               
    ---------+-------+-------------------+------------+--------------------
    PRCP     | 14    | GHCND:GM000004199 | ,,E,       | 2014-10-01T00:00:00
    SNWD     | 0     | GHCND:GM000004199 | ,,E,       | 2014-10-01T00:00:00
    TMAX     | 193   | GHCND:GM000004199 | ,,E,       | 2014-10-01T00:00:00
    TMIN     | 120   | GHCND:GM000004199 | ,,E,       | 2014-10-01T00:00:00
    PRCP     | 3     | GHCND:GME00111524 | ,,E,       | 2014-10-01T00:00:00
    SNWD     | 0     | GHCND:GME00111524 | ,,E,       | 2014-10-01T00:00:00
    TMAX     | 191   | GHCND:GME00111524 | ,,E,       | 2014-10-01T00:00:00
    TMIN     | 104   | GHCND:GME00111524 | ,,E,       | 2014-10-01T00:00:00
    #{IO.ANSI.format(["\n", :blue, :bright, "Metadata"], true)}
    limit | count | offset
    ------+-------+-------
    25    | 8     | 1     
    """
  end
end
