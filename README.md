# EctoTypesense

## Documentation

## Installation

Install with Hex from `ecto_typesense`:

```elixir
# mix.exs
def deps do
  [
    {:ecto_typesense, "~> 0.1.0"}
  ]
end
```

Set the following config options:

```elixir
# config/config.exs
config :ecto_typesense,
  url: "put-your-typesense-url-here",
  api_key: "put-your-api-key-here"
```

Typesense is very easy to run in docker compose. [See an example here](test/e2e/docker-compose.yml) of running it in the test suite!
