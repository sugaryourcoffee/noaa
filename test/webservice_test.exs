defmodule WebserviceTest do
  use ExUnit.Case

  test "dataset url should return a dataset" do
    url = "http://www.ncdc.noaa.gov/cdo-web/api/v2/datasets?limit=1"

    # result of the above call will return following raw data
    '''
    {:ok,{"results":[{"uid":"gov.noaa.ncdc:C00040","id":"ANNUAL",\
    "name":"Annual Summaries","datacoverage":1,"mindate":"1831-02-01",\
    "maxdate":"2014-07-01"}],\
    "metadata":{"resultset":{"limit":1,"count":11,"offset":1}}}}
    '''

    assert { :ok, _ } = Noaa.Webservice.fetch(url)
  end

  test "location url should return a location" do
    url = "http://www.ncdc.noaa.gov/cdo-web/api/v2/locations?limit=1"

    # result of the above call will return following raw data
    '''
    {:ok, {"results":[{"id":"CITY:AE000002","name":"Ajman, AE",\
    "datacoverage":0.6855,"mindate":"1944-03-01","maxdate":"2014-12-29"},"],\
    "metadata":{"resultset":{"limit":1,"count":38497,"offset":1}}}}
    '''

    assert { :ok, _ } = Noaa.Webservice.fetch(url)
  end

  test "location search should return a location id" do

  end

  test "data url should return weather data" do
    url = """
    http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GHCND&\
    locationid=CITY:GM000019&startdate=2014-10-01&enddate=2014-10-01\
    """
    # result of the above call will return following raw data
    '''
    {:ok,\
    {"results":[{"station":"GHCND:GM000004199","value":14,"attributes":",,E,",\
    "datatype":"PRCP","date":"2014-10-01T00:00:00"}],
    "metadata":{"resultset":{"limit":25,"count":248,"offset":1}}}}
    '''
    assert { :ok, _ } = Noaa.Webservice.fetch(url)
  end

end
