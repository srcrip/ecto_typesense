defmodule EctoTypesense.Schema do
  @moduledoc """
  Define functions to grab your Typesense collection schema off your Ecto schema.
  """

  @ecto_date_types [
    :date,
    :time,
    :time_usec,
    :naive_datetime,
    :naive_datetime_usec,
    :utc_datetime,
    :utc_datetime_usec
  ]

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
    # TODO: Several things in here should be pulled out into other functions.
    def coerce(schema) do
      # Pull the list of fields off this ecto Schema.
      fields = schema.__meta__.schema.__typesense_schema__(:fields)

      # Selecting only the 'name' field in that map.
      field_names =
        fields
        |> Enum.map(& &1[:name])
        |> Enum.map(fn x -> String.to_atom(x) end)

      # Map over fields, and try to add the known ecto type.
      fields =
        fields
        |> Enum.map(fn %{name: name} = f ->
          atom_name = String.to_atom(name)

          ecto_type =
            schema.__meta__.schema.__schema__(:type, atom_name) ||
              schema.__meta__.schema.__schema__(:virtual_type, atom_name)

          # try to add ecto type onto the field, if it exists
          if ecto_type do
            Map.put(f, :ecto_type, ecto_type)
          else
            f
          end
        end)

      # Remove any fields that aren't in the schema.
      fields =
        fields
        |> Enum.filter(fn %{name: name} ->
          field_names |> Enum.member?(String.to_atom(name))
        end)

      # Grab values off the schema
      values =
        schema
        |> Map.from_struct()
        |> Map.take(field_names)

      # Convert the field types to Typesense types.
      EctoTypesense.Schema.convert_typesense_types(values, fields)
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
    |> Enum.map(fn {k, value} ->
      field =
        Enum.find(fields, fn x ->
          x[:name] == to_string(k)
        end)
        |> Map.get(:type)

      ecto_type =
        Enum.find(fields, fn x ->
          x[:name] == to_string(k)
        end)
        |> Map.get(:ecto_type)

      {k, convert_typesense_type(value, field, ecto_type)}
    end)
    |> Enum.into(%{})
  end

  def convert_typesense_type(field, type, ecto_type) do
    # Check if ecto_type is one of ecto's date types
    if ecto_type in @ecto_date_types do
      DateTime.to_unix(field, :millisecond)
    else
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
end
