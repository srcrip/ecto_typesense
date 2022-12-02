defmodule TypesenseTest.Documents do
  @moduledoc false

  use EctoTypesenseTest.APICase

  alias Typesense.Documents

  @create_document_body %{name: "companies", fields: []}
  @tag mocks: %{
         collections: [],
         documents: [
           {"create", "collections/companies/documents", @create_document_body, [], %{}, :post}
         ]
       }
  test "create a document", %{fixtures: %{documents: %{"create" => body}}} do
    response = Documents.create("companies", @create_document_body)
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @tag mocks: %{
         collections: [],
         documents: [{"retrieve", "collections/companies/documents/124", "", [], %{}, :get}]
       }
  test "retrieve a document", %{fixtures: %{documents: %{"retrieve" => body}}} do
    response = Documents.retrieve("companies", "124")
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @search_params %{
    q: "stark",
    query_by: "company_name",
    filter_by: "num_employees:>100",
    sort_by: "num_employees:desc"
  }
  @tag mocks: %{
         collections: [],
         documents: [
           {"search",
            "collections/companies/documents/search?#{URI.encode_query(@search_params)}", "", [],
            @search_params, :get}
         ]
       }
  test "search documents", %{fixtures: %{documents: %{"search" => body}}} do
    response = Documents.search("companies", @search_params)
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @update_params %{
    company_name: 'Stark Industries',
    num_employees: 5500
  }
  @tag mocks: %{
         collections: [],
         documents: [
           {"update", "collections/companies/documents/124", @update_params, [], %{}, :patch}
         ]
       }
  test "update a document", %{fixtures: %{documents: %{"update" => body}}} do
    response = Documents.update("companies", "124", @update_params)
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @tag mocks: %{
         collections: [],
         documents: [{"delete", "collections/companies/documents/124", "", [], %{}, :delete}]
       }
  test "delete a document by id", %{fixtures: %{documents: %{"delete" => body}}} do
    response = Documents.delete("companies", "124")
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @delete_params %{
    filter_by: "num_employees:>=100",
    batch_size: 100
  }
  @tag mocks: %{
         collections: [],
         documents: [
           {"delete_query", "collections/companies/documents?#{URI.encode_query(@delete_params)}",
            "", [], @delete_params, :delete}
         ]
       }
  test "delete documents by query", %{fixtures: %{documents: %{"delete_query" => body}}} do
    response = Documents.delete("companies", @delete_params)
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @tag mocks: %{
         collections: [],
         documents: [{"export", "collections/companies/documents/export", "", [], %{}, :get}]
       }
  test "export documents", %{fixtures: %{documents: %{"export" => body}}} do
    response = Documents.export("companies")
    assert {:ok, ^body} = response
  end

  @import_documents [
    %{id: "1", company_name: "Stark Industries", num_employees: 5215, country: "USA"},
    %{id: "2", company_name: "Orbit Inc.", num_employees: 256, country: "UK"}
  ]
  @tag mocks: %{
         collections: [],
         documents: [
           {"import", "collections/companies/documents/import?action=create", @import_documents,
            [], %{}, :post}
         ]
       }
  test "import documents", %{fixtures: %{documents: %{"import" => body}}} do
    response = Documents.import("companies", @import_documents)
    assert {:ok, ^body} = response
  end

  defp jsonl_response({:ok, jsonl}) do
    jsonl
    |> Enum.split("\n")
    |> Enum.map(&Jason.decode!/1)
  end
end
