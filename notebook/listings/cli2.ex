defmodule Noaa.CLI do

  @default_count 10

  @moduledoc """
  Handle the command line parsing and dispatching to the respective functions
  that list the weather conditions of provided cities.
  """

  def run(argv) do
    parse_args(argv)
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
      { [ data: true, 
          dataset: dataset, 
          location: location, 
          from: from, 
          to: to ], _, _ }
        -> { :data, dataset, location, from, to }
      _ -> :help
    end
  end

end
