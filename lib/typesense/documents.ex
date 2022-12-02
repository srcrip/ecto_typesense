defmodule Typesense.Documents do
  @moduledoc """
  HTTP wrapper for Typesense Documents.
  """

  @doc """
  Index a document.

  ## Examples

  ```elixir
  iex> document = %{
    company_name: "Stark Industries",
    num_employees: 5215,
    country: "USA"
  }
  iex> Typesense.Documents.create(collection, document)
  {:ok, document}
  ```
  """
  @spec create(binary(), binary() | map()) :: {:ok, map()} | {:error, any()}
  def create(collection, document) do
    Typesense.post("/collections/#{collection}/documents", document)
  end

  @doc """
  Retrieve a document.

  ## Examples

  ```elixir
  iex> Typesense.Documents.retrieve(collection, id)
  {:ok, document}
  ```
  """
  def retrieve(collection, id) do
    Typesense.get("/collections/#{collection}/documents/#{id}")
  end

  @doc """
  Search for documents.

  ## Examples

  ```elixir
  iex> search_params = %{
    q: "stark",
    query_by: "company_name",
    filter_by: "num_employees:>100",
    sort_by: "num_employees:desc"
  }
  iex> Typesense.Documents.search(collection, search_params)
  iex> {:ok, documents}
  ```
  """
  def search(collection, query) do
    Typesense.get("/collections/#{collection}/documents/search", [], params: query)
  end

  @doc """
  Update a document.

  ## Examples

  ```elixir
  iex> Typesense.Documents.update(collection, id, document)
  {:ok, document}
  ```
  """
  # NOTE: Need to update all the others that take a document to specify binary or map?
  @spec update(binary(), binary(), binary() | map()) :: {:ok, map()} | {:error, any()}
  def update(collection, id, document) do
    Typesense.patch("/collections/#{collection}/documents/#{id}", document)
  end

  @doc """
  Delete a document by id, or several documents through a query.

  ## Examples

  ```elixir
  iex> Typesense.Documents.delete(collection, id)
  {:ok, _document}
  ```
  """
  @spec delete(binary(), binary() | integer() | map()) :: {:ok, map()} | {:error, any()}
  def delete(collection, id) when is_integer(id) or is_binary(id) do
    Typesense.delete("/collections/#{collection}/documents/#{id}")
  end

  def delete(collection, query) when is_map(query) do
    Typesense.delete("/collections/#{collection}/documents", [], params: query)
  end

  @doc """
  Export documents from a collection.

  ## Examples

  ```elixir
  iex> Typesense.Documents.export(collection)
  [%{}, ...]
  """
  def export(collection) do
    Typesense.get("/collections/#{collection}/documents/export", [], parse: :jsonl)
  end

  @doc """
  Import documents into a collection.

  ## Examples

  ```elixir
  iex> documents = [%{
    id: "124",
    company_name: "Stark Industries",
    num_employees: 5215,
    country: "USA"
  }]
  iex> Typesense.Documents.import(collection, documents, :create)
  {:ok, documents}
  """
  def import(collection, documents, action \\ :create) do
    Typesense.post(
      "/collections/#{collection}/documents/import?action=#{action}",
      prepare_jsonl(documents),
      [],
      parse: :jsonl
    )
  end

  defp prepare_jsonl(documents) when is_list(documents) do
    Enum.map_join(documents, "\n", &Jason.encode!/1)
  end

  defp prepare_jsonl(documents) when is_binary(documents) do
    documents
  end
end
