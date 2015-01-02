defmodule Noaa.CLI do

  @default_count 10

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
  `argv` can be one of the following options.

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
                   to: to ]), do: { :data, dataset, location, from, to }

  def parse_remains({ parse, _, _ }) do
    parse_remains(Enum.map([:data, :dataset, :location, :from, :to], 
                        fn(x) -> List.keyfind(parse, x, 0) end))
  end

  def parse_remains(_), do: :help

  def process(:help) do
    IO.puts """
    noaa fetches weather data from NOAA

    usage: noaa command args
          
    noaa --datasets  [ --count [ count | #{@default_count} ] ]
    noaa --locations [ --count [ count | #{@default_count} ] | --search city ]
    noaa --data      --dataset dataset --location location --from YYYY-MM-DD \
                     --to YYYY-MM-DD
    """
    System.halt(0)
  end

  def process({:datasets, count}) do
    "#{count} datasets"
  end

  def process({:locations, count}) when is_integer(count) do
    "#{count} locations"
  end

  def process({:locations, city}) do
    "#{city} location"
  end

  def process({:data, values}) do
    "Data for specified city"
  end
end
