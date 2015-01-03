defmodule DecodeTest do
  use ExUnit.Case

  import Noaa.CLI, only: [ decode_response: 1 ]

  def test_body do
    [{"results",
      [[{"uid", "gov.noaa.ncdc:C00040"}, {"id", "ANNUAL"},
        {"name", "Annual Summaries"}, {"datacoverage", 1},
        {"mindate", "1831-02-01"}, {"maxdate", "2014-07-01"}]]},
     {"metadata", [{"resultset", [{"limit", 1}, {"count", 11}, 
                   {"offset", 1}]}]}] 
  end

  def test_results do
    [[{"uid", "gov.noaa.ncdc:C00040"}, {"id", "ANNUAL"},
      {"name", "Annual Summaries"}, {"datacoverage", 1}, 
      {"mindate", "1831-02-01"},
      {"maxdate", "2014-07-01"}]]
  end

  def test_metadata do
    [{"limit", 1}, {"count", 11}, {"offset", 1}] 
  end

  test "decode for successful response" do
    assert decode_response({:ok, test_body}) == [ test_results, test_metadata ]
  end

end
