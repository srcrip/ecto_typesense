defmodule EctoTypesense.Documents do
  @moduledoc """
  Interact with Typesense documents by passing Ecto schemas.
  """

  alias EctoTypesense.Collections
  alias EctoTypesense.Schema.DocumentProtocol

  @spec create(Ecto.Schema.t()) :: {:ok, map()} | {:error, any()}
  def create(document) do
    Collections.collection(document.__meta__.schema)
    |> Typesense.Documents.create(DocumentProtocol.coerce(document))
  end

  @spec retrieve(Ecto.Schema.t()) :: {:ok, map()} | {:error, any()}
  def retrieve(document) do
    Collections.collection(document.__meta__.schema)
    |> Typesense.Documents.retrieve(DocumentProtocol.id(document))
  end

  @spec retrieve(Ecto.Queryable.t(), term()) :: {:ok, map()} | {:error, any()}
  def retrieve(module, id) do
    Collections.collection(module)
    |> Typesense.Documents.retrieve(id)
  end

  @spec search(Ecto.Queryable.t(), map()) :: {:ok, map()} | {:error, any()}
  def search(module, query) do
    Collections.collection(module)
    |> Typesense.Documents.search(query)
  end

  @spec update(Ecto.Queryable.t()) :: {:ok, map()} | {:error, any()}
  def update(document) do
    Collections.collection(document.__meta__.schema)
    |> Typesense.Documents.update(
      DocumentProtocol.id(document),
      DocumentProtocol.coerce(document)
    )
  end

  @spec update(Ecto.Queryable.t(), term(), Ecto.Schema.t()) :: {:ok, map()} | {:error, any()}
  def update(module, id, document) do
    Collections.collection(module)
    |> Typesense.Documents.update(id, DocumentProtocol.coerce(document))
  end

  @spec delete(Ecto.Schema.t()) :: {:ok, map()} | {:error, any()}
  def delete(document) do
    Collections.collection(document.__meta__.schema)
    |> Typesense.Documents.delete(DocumentProtocol.id(document))
  end

  @spec delete(Ecto.Queryable.t(), term()) :: {:ok, map()} | {:error, any()}
  def delete(module, id) do
    Collections.collection(module)
    |> Typesense.Documents.delete(id)
  end

  @spec export(Ecto.Queryable.t()) :: {:ok, map()} | {:error, any()}
  def export(module) do
    Collections.collection(module)
    |> Typesense.Documents.export()
  end

  @spec import(Ecto.Queryable.t(), list(Ecto.Schema.t())) :: {:ok, map()} | {:error, any()}
  def import(module, documents) do
    Collections.collection(module)
    |> Typesense.Documents.import(documents)
  end

  @spec import(list(Ecto.Schema.t())) :: {:ok, map()} | {:error, any()}
  def import([]), do: raise("imported documents list cannot be empty")

  def import(documents) do
    documents
    |> Enum.map(& &1.__meta__.schema)
    |> Enum.frequencies()
    |> Map.keys()
    |> length()
    |> case do
      1 ->
        Collections.collection(List.first(documents).__meta__.schema)
        |> Typesense.Documents.import(as_jsonl(documents))

      _ ->
        raise "all imported documents must be of the same type"
    end
  end

  @spec as_jsonl(list(Ecto.Schema.t())) :: term
  defp as_jsonl(schemas) when is_list(schemas) do
    schemas
    |> Enum.map_join("\n", &DocumentProtocol.coerce/1)
  end
end
