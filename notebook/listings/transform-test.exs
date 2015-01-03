defmodule TransformTest do
  use ExUnit.Case

  import Noaa.CLI, only: [ transform_to_hashdicts: 1 ]

  def test_results do
    [[{"uid", "gov.noaa.ncdc:C00040"}, {"id", "ANNUAL"},
      {"name", "Annual Summaries"}, {"datacoverage", 1}, 
      {"mindate", "1831-02-01"},
      {"maxdate", "2014-07-01"}]]
  end

  def test_metadata do
    [{"limit", 1}, {"count", 11}, {"offset", 1}] 
  end

  test "transformation of results and metadata into HashDict" do
    [ results, metadata ] = transform_to_hashdicts([test_results, 
                                                    test_metadata])
    assert is_list results
    assert is_list metadata
  end

end
