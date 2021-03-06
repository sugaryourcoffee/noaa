defmodule Noaa.CLI do

  @default_count 10
  @max_count 1000

  @moduledoc """
  Handle the command line parsing and dispatching to the respective functions
  that list the weather conditions of provided cities.
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be used with one of the following options.

  * datasets  --count   COUNT
  * locations --count   COUNT
  * locations --search  CITY
  * data      --dataset DATASET --location LOCATION --from DATE --to DATE

  Return the tuple of `{:dataset, COUNT}`, `{:locations, COUNT}`,
  `{:locations, CITY}`, `{:data, DATASET, LOCATION, DATE, DATE}` or :help. 
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv,
                               switches: [ help:      :boolean,
                                           datasets:  :boolean,
                                           locations: :boolean,
                                           data:      :boolean,
                                           count:     :integer,
                                           search:    :string,
                                           dataset:   :string,
                                           location:  :string,
                                           from:      :string,
                                           to:        :string ],
                               aliases:  [ h:         :help,
                                           c:         :count,
                                           s:         :search,
                                           d:         :dataset,
                                           l:         :location,
                                           f:         :from,
                                           t:         :to ])

    case parse do
      { [ help: true ], _, _ }
        -> :help
      { [ datasets: true, count: count ], _, _ }
        -> { :dataset, count }
      { [ datasets: true ], _, _ }
        -> { :dataset, @default_count }
      { [ locations: true, count: count ], _, _ }
        -> { :location, count }
      { [ locations: true ], _, _ }
        -> { :location, @default_count }
      { [ locations: true, location: location ], _, _ }
        -> { :location, location }
      _ -> parse_remains(parse)
    end
  end

  def parse_remains([ data: true, 
                   dataset: dataset, 
                   location: location,
                   from: from, 
                   to: to ]), do: { :data, [dataset:  dataset, 
                                            location: location, 
                                            from:     from, 
                                            to:       to] }

  def parse_remains({ parse, _, _ }) do
    parse_remains(Enum.map([:data, :dataset, :location, :from, :to], 
                        fn(x) -> List.keyfind(parse, x, 0) end))
  end

  def parse_remains(_), do: :help

  def process(:help) do
    IO.puts """
    noaa fetches weather data from NOAA at http://www.ncdc.noaa.gov

    usage: noaa command args
          
    noaa --datasets  [ --count [ count | #{@default_count} ] ]
    noaa --locations [ --count [ count | #{@default_count} ] | --search city ]
    noaa --data      --dataset dataset --location location --from YYYY-MM-DD \
                     --to YYYY-MM-DD
    """
    System.halt(0)
  end

  def process({:datasets, count}) do
    print(datasets_url(count), "Datasets", 
          [ "name", "id", "mindate", "maxdate", "datacoverage" ])
  end

  def process({:locations, count}) when is_integer(count) do
    print(locations_url(count), "Locations", 
          [ "name", "id", "mindate", "maxdate", "datacoverage" ])
  end

  def process({:locations, city}) do
    locations_url(@max_count)
  end

  def process({:data, values}) do
    print(data_url(values), "Weather Data", 
          [ "datatype", "value", "station", "attributes", "date" ])
  end

  def datasets_url(count) do
    "http://www.ncdc.noaa.gov/cdo-web/api/v2/datasets?limit=#{count}"
  end

  def locations_url(count) do
    "http://www.ncdc.noaa.gov/cdo-web/api/v2/locations?limit=#{count}"
  end

  def data_url(values) do
    """
    http://www.ncdc.noaa.gov/cdo-web/api/v2/data?\
    datasetid=#{values[:dataset]}&\
    locationid=#{values[:location]}&\
    startdate=#{values[:from]}&\
    enddate=#{values[:to]}\
    """
  end

  def decode_response({:ok, body}) do 
    [ { _, results }, { _, [ { _, metadata } ] } ] = body
    [ results, metadata ]
  end

  def decode_response({:error, reason}) do
    {_, message} = List.keyfind(reason, "message", 0)
    IO.puts "Error fetching data from NOAA: #{message}"
    System.halt(2) 
  end

  def transform_to_hashdicts([ results | metadata ]) do
    [ results  |> Enum.map(&Enum.into(&1, HashDict.new)),
      metadata |> Enum.map(&Enum.into(&1, HashDict.new)) ] 
  end

  def print(url, title, columns) do
    [results, metadata] = url
    |> Noaa.Webservice.fetch
    |> decode_response
    |> transform_to_hashdicts

    IO.puts(IO.ANSI.format(["\n", :blue, :bright, title], true))
    Noaa.TableFormatter.print(results, columns)
    IO.puts(IO.ANSI.format(["\n", :blue, :bright, "Metadata"], true))
    Noaa.TableFormatter.print(metadata, [ "limit", "count", "offset" ])
   end
end
