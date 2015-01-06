defmodule Noaa.CLI do

  @default_count 10
  @max_count 1000

  @moduledoc """
  Handle the command line parsing and dispatching to the respective functions
  that list the weather conditions of provided cities.
  """

  def main(argv) do
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
        -> { :datasets, count }
      { [ datasets: true ], _, _ }
        -> { :datasets, @default_count }
      { [ locations: true, count: count ], _, _ }
        -> { :locations, count }
      { [ locations: true ], _, _ }
        -> { :locations, @default_count }
      { [ locations: true, location: location ], _, _ }
        -> { :locations, location }
      _ -> parse_remains(parse)
    end
  end

  @doc """
  Command line parameters can be given in an arbitrary sequence. We check the
  switches given for completeness and order them in the required sequence. Then
  we kick them off again whether they match a given command. In this case we
  check for the :data command.
  """
  def parse_remains([ data: true, 
                   dataset: dataset, 
                   location: location,
                   from: from, 
                   to: to ]), do: { :data, [dataset:  dataset, 
                                            location: location, 
                                            from:     from, 
                                            to:       to] }

  @doc """
  All commands and their parameters are not matched within argsv/1 are checked
  in the parse_remains/1 functions and try to put the command and switches
  given in the right order. The we kick them off again whether it matches a
  command. 
  """
  def parse_remains({ parse, _, _ }) do
    parse_remains(Enum.map([:data, :dataset, :location, :from, :to], 
                        fn(x) -> List.keyfind(parse, x, 0) end))
  end

  @doc """
  If none of the other commands match, then :help is invoked
  """
  def parse_remains(_), do: :help

  @doc """
  Prints the help message if the command line parameters do not match a command.
  Exits the application after printing the help message.

  ## Example
      iex> Noaa.CLI.process(:help)
  """
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

  @doc """
  Processes the datasets command and prints the available datasets limitted by
  the count parameter.

  ## Example
      iex> Noaa.CLI.process({:datasets, 1})
  """
  def process({:datasets, count}) do
    print(datasets_url(count), "Datasets", 
          [ "name", "id", "mindate", "maxdate", "datacoverage" ])
  end

  @doc """
  Processes the locations command and prints the available locations limitted
  by the count parameter.

  ## Example
      iex> Noaa.CLI.process({:locations, 10})
  """
  def process({:locations, count}) when is_integer(count) do
    print(locations_url(count), "Locations", 
          [ "name", "id", "mindate", "maxdate", "datacoverage" ])
  end

  @doc """
  Searches for the location specified by the city parameter. This will obtain
  the locationid which is necessary for the data command.
  Note: Not yet implemented.

  ## Example
      iex> Noaa.CLI.process({:locations, "Munich"})
  """
  def process({:locations, city}) do
    locations_url(@max_count)
  end

  @doc """
  Processes the data command and finally prints the weather data of the
  specified location. A location can be obtained by the locations command.

  ## Example
      iex> Noaa.CLI.process({:data, [datasets: "GHCND", 
      ...>                           location: "CITY:AE000002", 
      ...>                           from: "2014-10-01", to: "2014-10-01"] 
  """
  def process({:data, values}) do
    print(data_url(values), "Weather Data", 
          [ "datatype", "value", "station", "attributes", "date" ])
  end

  @doc """
  Returns the datasets URL
  """
  def datasets_url(count) do
    "http://www.ncdc.noaa.gov/cdo-web/api/v2/datasets?limit=#{count}"
  end

  @doc """
  Returns the locations URL
  """
  def locations_url(count) do
    "http://www.ncdc.noaa.gov/cdo-web/api/v2/locations?limit=#{count}"
  end

  @doc """
  Returns the data URL
  """
  def data_url(values) do
    """
    http://www.ncdc.noaa.gov/cdo-web/api/v2/data?\
    datasetid=#{values[:dataset]}&\
    locationid=#{values[:location]}&\
    startdate=#{values[:from]}&\
    enddate=#{values[:to]}\
    """
  end

  @doc """
  Returns the bodies for the results and metadata in raw format
  """
  def decode_response({:ok, body}) do 
    [ { _, results }, { _, [ { _, metadata } ] } ] = body
    [ results, metadata ]
  end

  @doc """
  In case there is an error when fetching data from NOAA the error message is
  printed and the application exits with code 2.
  """
  def decode_response({:error, reason}) do
    {_, message} = List.keyfind(reason, "message", 0)
    IO.puts "Error fetching data from NOAA: #{message}"
    System.halt(2) 
  end

  @doc """
  Transforms the bodies results and metadata into HashDicts.
  """
  def transform_to_hashdicts([ results | metadata ]) do
    [ results  |> Enum.map(&Enum.into(&1, HashDict.new)),
      metadata |> Enum.map(&Enum.into(&1, HashDict.new)) ] 
  end

  @doc """
  Prints the data in a table format containing the results and the metadata
  """
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
