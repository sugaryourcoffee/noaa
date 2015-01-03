defmodule CliTest do
  use ExUnit.Case

  import Noaa.CLI, only: [ parse_args: 1 ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["--help", "anything"]) == :help
    assert parse_args(["-h",     "anything"]) == :help
  end
 
  test ":datasets returned with default count when only dataset is given" do
    assert parse_args(["--datasets"]) == { :dataset, 10 }
  end

  test ":datasets returned with count if dataset and count is given" do
    assert parse_args(["--datasets", "--count", "5"]) == { :dataset, 5 }
    assert parse_args(["--datasets", "-c",      "5"]) == { :dataset, 5 }
  end

  test ":location returned with default count if only location is given" do
    assert parse_args(["--locations"]) == { :location, 10 }
  end

  test ":location returned with count if location and count is given" do
    assert parse_args(["--locations", "--count", "8"]) == { :location, 8 }
    assert parse_args(["--locations", "-c",     "8"])  == { :location, 8 }
  end

  test ":location returned with city location and city is given" do
    assert parse_args(["--locations", 
                       "--location", 
                       "Munich"]     ) == { :location, "Munich" }
  end

  test ":data returned with values provided in the correct sequence" do
    assert parse_args(["--data",
                       "--dataset",  "ABCD",
                       "--location", "Munich",
                       "--from",     "2014-12-24",
                       "--to",       "2015-01-01"]) == { :data, 
                                                         [dataset: "ABCD",
                                                         location: "Munich",
                                                         from: "2014-12-24",
                                                         to: "2015-01-01"] }
  end

  test ":data returned with values provided in arbitrary sequence" do
    assert parse_args(["--data",
                       "--location", "Munich",
                       "--from",     "2014-12-24",
                       "--to",       "2015-01-01",
                       "--dataset",  "ABCD"]      ) == { :data,
                                                         [dataset: "ABCD",
                                                         location: "Munich",
                                                         from: "2014-12-24",
                                                         to: "2015-01-01"] }
  end

end
