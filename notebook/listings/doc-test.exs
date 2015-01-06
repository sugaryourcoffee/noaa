defmodule DocTest do
  use ExUnit.Case

  doctest Noaa.CLI
  doctest Noaa.TableFormatter
  doctest Noaa.Webservice
end
