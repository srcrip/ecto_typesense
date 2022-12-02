defmodule EctoTypesense.Collections do
  @moduledoc """
  Interact with Typesense collections from an Ecto schema.
  """

  def create_collection(module) do
    collection(module)
    |> Typesense.Collections.create()
  end

  def retrieve_collection(module) do
    collection(module)
    |> Typesense.Collections.retrieve()
  end

  def delete_collection(module) do
    collection(module)
    |> Typesense.Collections.delete()
  end

  def collection(module) do
    module.__typesense_schema__(:name)
  end
end
