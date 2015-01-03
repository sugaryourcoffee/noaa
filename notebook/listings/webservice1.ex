defmodule Noaa.Webservice do
  @token [ { "token", "pLCcTVobSdphuEvXyOyhkAbVlObmWQra" } ] 

  def fetch(url) do
    url
    |> HTTPoison.get(@token)
    |> handle_response
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, 
                                                body: body}}) do
    { :ok, body } #:jsx.decode(body) }
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    { :error, [{"message", "Page not found"}] }
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    { :error, reason } #:jsx.decode(reason) }
  end


end
