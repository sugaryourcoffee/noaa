defmodule Noaa.Webservice do
  @token [ { "token", "pLCcTVobSdphuEvXyOyhkAbVlObmWQra" } ] 

  @moduledoc """
  Fetches the weather data with the NOAA webservice
  """

  @doc """
  Fetch data from NOAA and returns the decoded response
  """
  def fetch(url) do
    url
    |> HTTPoison.get(@token)
    |> handle_response
  end

  @doc """
  Fetches the data and returns raw JSON data without handling the response
  """
  def fetch_raw(url) do
    url
    |> HTTPoison.get(@token)
  end

  @doc """
  Returns the decoded body after a sucessful response { :ok, body }
  """
  def handle_response({:ok, %HTTPoison.Response{status_code: 200, 
                                                body: body}}) do
    { :ok, :jsx.decode(body) }
  end

  @doc """
  Returns the error message when page is not found { :error, reason }
  """
  def handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    { :error, [{"message", "Page not found"}] }
  end

  @doc """
  Returns an error message when an error occured during the fetch
  { :error, reason }
  """
  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    { :error, :jsx.decode(reason) }
  end


end
