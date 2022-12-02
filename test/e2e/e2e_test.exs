defmodule E2ETest do
  @moduledoc """
  Test against a real instance of Typesense.
  """

  use ExUnit.Case

  alias Typesense.Collections
  alias Typesense.Documents

  test "create a collection" do
    {:ok, result} =
      Collections.create(%{
        name: "companies",
        fields: [
          %{name: "company_name", type: "string", facet: false},
          %{name: "num_employees", type: "int32", facet: false},
          %{name: "country", type: "string", facet: true}
        ],
        default_sorting_field: "num_employees"
      })

    assert %{
             "default_sorting_field" => "num_employees",
             "fields" => [
               %{
                 "facet" => false,
                 "index" => true,
                 "name" => "company_name",
                 "optional" => false,
                 "type" => "string"
               },
               %{
                 "facet" => false,
                 "index" => true,
                 "name" => "num_employees",
                 "optional" => false,
                 "type" => "int32"
               },
               %{
                 "facet" => true,
                 "index" => true,
                 "name" => "country",
                 "optional" => false,
                 "type" => "string"
               }
             ],
             "name" => "companies"
           } = result
  end

  test "retrieve a collection" do
    {:ok, result} = Collections.retrieve("companies")

    assert %{
             "default_sorting_field" => "num_employees",
             "fields" => [
               %{"name" => "company_name", "type" => "string"},
               %{"name" => "num_employees", "type" => "int32"},
               %{"facet" => true, "name" => "country", "type" => "string"}
             ],
             "name" => "companies"
           } = result
  end

  test "list a collection" do
    {:ok, result} = Collections.list()

    assert [
             %{
               "default_sorting_field" => "num_employees",
               "fields" => [
                 %{"name" => "company_name", "type" => "string"},
                 %{"name" => "num_employees", "type" => "int32"},
                 %{"facet" => true, "name" => "country", "type" => "string"}
               ],
               "name" => "companies"
             }
           ] = result
  end

  test "index a document" do
    {:ok, result} =
      Documents.create("companies", %{
        id: "124",
        company_name: "Stark Industries",
        num_employees: 5215,
        country: "USA"
      })

    assert %{
             "company_name" => "Stark Industries",
             "country" => "USA",
             "id" => "124",
             "num_employees" => 5215
           } = result
  end

  test "search documents" do
    {:ok, result} =
      Documents.search("companies", %{
        q: "stark",
        query_by: "company_name",
        filter_by: "num_employees:>100",
        sort_by: "num_employees:desc"
      })

    assert %{
             "facet_counts" => [],
             "found" => 1,
             "hits" => [
               %{
                 "document" => %{
                   "company_name" => "Stark Industries",
                   "country" => "USA",
                   "id" => "124",
                   "num_employees" => 5215
                 },
                 "highlights" => [
                   %{
                     "field" => "company_name",
                     "matched_tokens" => ["Stark"],
                     "snippet" => "<mark>Stark</mark> Industries"
                   }
                 ]
               }
             ],
             "out_of" => 1,
             "page" => 1,
             "request_params" => %{
               "collection_name" => "companies",
               "per_page" => 10,
               "q" => "stark"
             }
           } = result
  end

  test "delete a collection" do
    {:ok, result} = Collections.delete("companies")

    assert %{
             "default_sorting_field" => "num_employees",
             "fields" => [
               %{"name" => "company_name", "type" => "string"},
               %{"name" => "num_employees", "type" => "int32"},
               %{"facet" => true, "name" => "country", "type" => "string"}
             ],
             "name" => "companies"
           } = result
  end
end
