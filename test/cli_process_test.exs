defmodule CliProcessTest do
  use ExUnit.Case
  import Noaa.CLI, only: [ process: 1 ]

  test "process :datasets to fetch datasets" do
    result = Noaa.CLI.process({:datasets, 10})

    assert result == "10 datasets"
  end

  test "process :locations to fetch locations" do
    result = Noaa.CLI.process({:locations, 10})

    assert result == "10 locations"
  end

  test "process :locations to search for a city" do
    result = Noaa.CLI.process({:locations, "Munich"})

    assert result == "Munich location"
  end

  test "process :data to fetch data for a specified city" do
    result = Noaa.CLI.process({:data, 
                              ["GHCND", 
                              "CITY:GM000019", 
                              "2014-10-01", 
                              "2015-01-01"]})

    assert result == "Data for specified city"
  end
end
