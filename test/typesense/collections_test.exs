defmodule TypesenseTest.Collections do
  @moduledoc false

  use EctoTypesenseTest.APICase

  alias Typesense.Collections

  @create_schema_body %{name: "companies", fields: []}
  @tag mocks: %{
         collections: [{"create", "collections", @create_schema_body, [], %{}, :post}],
         documents: []
       }
  test "create a collection", %{fixtures: %{collections: %{"create" => body}}} do
    response = Collections.create(@create_schema_body)
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @tag mocks: %{
         collections: [{"retrieve", "collections/companies", "", [], %{}, :get}],
         documents: []
       }
  test "retrieve a collection", %{fixtures: %{collections: %{"retrieve" => body}}} do
    response = Collections.retrieve("companies")
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end

  @tag mocks: %{
         collections: [{"list", "collections", "", [], %{}, :get}],
         documents: []
       }
  test "list all collections", %{fixtures: %{collections: %{"list" => body}}} do
    response = Collections.list()
    expected = Jason.decode!(body)
    assert {:ok, ^expected} = response
  end
end
