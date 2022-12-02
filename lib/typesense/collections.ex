defmodule Typesense.Collections do
  @moduledoc """
  The `Typesense.Collections` module is the service implementation for Typesense' `Collections` API Resource.
  """

  @type schema :: %{
          required(:name) => String.t(),
          required(:fields) =>
            list(%{
              required(:name) => String.t(),
              required(:type) => String.t(),
              optional(:facet) => boolean(),
              optional(:optional) => boolean()
            }),
          optional(:default_sorting_field) => integer()
        }

  @doc """
  Create a Collection.

  ## Examples

  ```
  schema = %{
    name: "companies",
    fields: [
      %{name: "company_name", type: "string"},
      %{name: "num_employees", type: "int32"},
      %{name: "country", type: "string", facet: true},
    ],
    default_sorting_field: "num_employees"
  }
  Typesense.Collections.create(schema)
  ```
  """
  @spec create(schema) :: {:ok, map()} | {:error, map()}
  def create(schema) do
    Typesense.post("/collections", schema)
  end

  @doc """
  Retrieve a collection.

  ## Examples

  ```elixir
  iex> Typesense.Collections.retrieve("companies")
  {:ok, company}
  ```
  """
  @spec retrieve(binary()) :: {:ok, map()} | {:error, any()}
  def retrieve(collection) do
    Typesense.get("/collections/#{collection}")
  end

  @doc """
  List all collections.

  ## Examples

  ```elixir
  iex> Typesense.Collections.list()
  {:ok, collections}
  ```
  """
  @spec list() :: {:ok, list()} | {:error, any()}
  def list do
    Typesense.get("/collections")
  end

  @doc """
  Delete a collection.

  ## Examples

  ```elixir
  iex> Typesense.Collections.delete(collection_id)
  {:ok, _collection}
  ```
  """
  @spec delete(binary()) :: {:ok, any()} | {:error, any()}
  def delete(id) do
    Typesense.delete("/collections/#{id}")
  end
end
