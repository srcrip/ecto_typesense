defmodule Typesense do
  @moduledoc """
  HTTPoison client for the Typesense API.
  """

  alias HTTPoison.{AsyncResponse, Base, Error, Request, Response}

  use Base

  @default_headers [{"Content-Type", "application/json"}]
  @default_options [parse: :json]

  @impl Base
  def process_request_options(options) do
    Keyword.merge(@default_options, options)
  end

  @impl Base
  def process_url(url) do
    Application.fetch_env!(:ecto_typesense, :url) <> url
  end

  @impl Base
  def process_request_headers(headers) do
    api_key = Application.fetch_env!(:ecto_typesense, :api_key)
    @default_headers ++ [{"X-TYPESENSE-API-KEY", api_key}] ++ headers
  end

  @impl Base
  def process_request_body(body) when is_map(body) do
    Jason.encode!(body)
  end

  def process_request_body(body) do
    body
  end

  @impl Base
  def process_response(%Response{
        status_code: status,
        body: body,
        request: %Request{
          options: options
        }
      })
      when status in 200..299 do
    case options[:parse] do
      :json -> json(body)
      :jsonl -> jsonl(body)
      _ -> {:ok, body}
    end
  end

  @impl Base
  def process_response(response), do: response

  @spec health() :: {:ok, Response.t() | AsyncResponse.t()} | {:error, Error.t()}
  def health, do: HTTPoison.get("/health")

  defp jsonl(string) do
    string
    |> String.split("\n")
    |> Enum.map(&json/1)
  end

  defp json(string) do
    case Jason.decode(string) do
      {:ok, json} -> json
      {:error, _} -> string
    end
  end
end
