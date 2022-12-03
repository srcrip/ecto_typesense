defmodule EctoTypesense.Schema do
  @moduledoc """
  Define functions to grab your Typesense collection schema off your Ecto schema.
  """

  defmacro collection(schema) do
    quote do
      Module.put_attribute(__MODULE__, :typesense_schema, unquote(schema))

      def __typesense_schema__(:source) do
        @typesense_schema
      end

      def __typesense_schema__(:name) do
        @typesense_schema[:name]
      end

      def __typesense_schema__(:fields) do
        @typesense_schema[:fields]
      end
    end
  end

  defprotocol DocumentProtocol do
    @doc """
    Used to convert Ecto schemas into Maps to pass to Typesense. This is implemented as a protocol instead of just Jason derive, because you may want to load more content before indexing something.
    """
    @fallback_to_any true
    @spec coerce(Ecto.Schema.t()) :: binary()
    def coerce(schema)
    @spec id(Ecto.Schema.t()) :: binary()
    def id(schema)
  end

  defimpl DocumentProtocol, for: Any do
    # Coerce the Ecto schema into a map that matches the Typesense schema.
    def coerce(schema) do
      # Pull the list of fields off this ecto Schema.
      fields = schema.__meta__.schema.__typesense_schema__(:fields)

      # Selecting only the 'name' field in that map.
      field_names =
        fields
        |> Enum.map(& &1[:name])
        |> Enum.map(fn x -> String.to_atom(x) end)

      schema
      |> Map.from_struct()
      # Remove any fields that aren't in the Typesense schema.
      |> Map.take(field_names)
      # Convert the field types to Typesense types.
      |> EctoTypesense.Schema.convert_typesense_types(fields)
      # Convert to JSON.
      |> Jason.encode!()
    end

    # Get the field used as the documents ID.
    def id(schema) do
      schema.id
      |> to_string()
    end
  end

  # Given a map of fields and the schema's fields try to coerce the values into expected Typesense types.
  def convert_typesense_types(map, fields) do
    map
    |> Enum.map(fn {k, v} ->
      field =
        Enum.find(fields, fn x ->
          x[:name] == to_string(k)
        end)
        |> Map.get(:type)

      {k, convert_typesense_type(v, field)}
    end)
    |> Enum.into(%{})
  end

  def convert_typesense_type(field, type) do
    case type do
      "int32" -> Integer.parse(field)
      "int64" -> Integer.parse(field)
      "float" -> Float.parse(field)
      "string" -> to_string(field)
      "bool" -> String.to_existing_atom(field)
      _ -> field
    end
  end
end
