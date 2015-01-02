defmodule CliTest do
  use ExUnit.Case

  import Noaa.CLI, only: [ parse_args: 1 ]

  test ":help returned by option parsing with -h and --help options" do
  end

  test ":datasets returned with default count when only dataset is given" do
  end

  test ":datasets returned with count if dataset and count is given" do
  end

  test ":help returned if datasets w/o correct switches is given" do
  end

  test ":location returned with default count if only location is given" do
  end

  test ":location returned with count if location and count is given" do
  end

  test ":location returned with city location and city is given" do
  end

  test ":help returned if location w/o correct switches is given" do
  end

  test ":data returned with -s, -d, -b and -e if all required data is given" do
  end

  test ":help returned if data w/o correct switches is given" do
  end
  
end
