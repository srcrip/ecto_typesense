defmodule EctoTypesenseTest.APICase do
  @moduledoc false

  use ExUnit.CaseTemplate
  use Mimic

  alias TypesenseTest.Fixtures

  @url "http://localhost:8109/"

  def mock_request(path, request_body, headers, params, options, method) do
    headers = [{"Content-Type", "application/json"}, {"X-TYPESENSE-API-KEY", "secret"}] ++ headers

    if map_size(params) == 0 do
      %HTTPoison.Request{
        method: method,
        url: @url <> path,
        headers: headers,
        body: request_body,
        options: options
      }
    else
      %HTTPoison.Request{
        method: method,
        url: @url <> path,
        headers: headers,
        body: request_body,
        params: params,
        options: Keyword.merge(options, params: params)
      }
    end
  end

  def mock_api(url, response_body, request_body, headers, params, options, method) do
    request = mock_request(url, request_body, headers, params, options, method)

    expect(HTTPoison.Base, :request, fn _module,
                                        ^request,
                                        _process_response_status_code,
                                        _process_response_headers,
                                        process_response_body,
                                        process_response ->
      response_body
      |> process_response_body.()
      |> then(fn body ->
        %HTTPoison.Response{
          status_code: 200,
          body: body,
          request: request
        }
      end)
      |> process_response.()
      |> then(fn response -> {:ok, response} end)
    end)
  end

  def mock_requests(category, mocks) do
    mocks
    |> Enum.map(fn {key, url, request_body, headers, params, method} ->
      parse = if key in ["import", "export"], do: :jsonl, else: :json
      options = [parse: parse]

      response_body =
        Fixtures.load(category <> "/" <> key)
        |> String.replace_suffix("\n", "")

      request_body = prepare_request_body(request_body, parse)

      mock_api(
        url,
        response_body,
        request_body,
        headers,
        params,
        options,
        method
      )

      expected_response_body =
        response_body
        |> prepare_response_body(parse)

      {key, expected_response_body}
    end)
    |> Enum.into(%{})
    |> then(fn fixtures -> %{fixtures: fixtures} end)
  end

  def prepare_response_body(body, :jsonl) do
    body
    |> String.split("\n")
    |> Enum.map(&Jason.decode!/1)
  end

  def prepare_response_body(body, _), do: body

  def prepare_request_body(body, :jsonl) when is_list(body) do
    Enum.map_join(body, "\n", &Jason.encode!/1)
  end

  def prepare_request_body(body, :jsonl) when is_binary(body) do
    body
  end

  def prepare_request_body(body, :json) when is_map(body) do
    Jason.encode!(body)
  end

  def prepare_request_body(body, _parse) do
    body
  end

  setup %{mocks: %{collections: collection_mocks, documents: document_mocks}} do
    collection_fixtures = mock_requests("collections", collection_mocks)
    document_fixtures = mock_requests("documents", document_mocks)

    %{
      fixtures: %{
        collections: collection_fixtures.fixtures,
        documents: document_fixtures.fixtures
      }
    }
  end
end
