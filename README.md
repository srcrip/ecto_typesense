<h1 align="center">
  EctoTypesense
</h1>

<div align="center">

  [![Build Status](https://github.com/sevensidedmarble/ecto_typesense/workflows/CI/badge.svg)](https://github.com/sevensidedmarble/ecto_typesense/actions/workflows/ci.yml)
  [![Hex.pm](https://img.shields.io/hexpm/v/ecto_typesense.svg)](https://hex.pm/packages/ecto_typesense)
  [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/ecto_typesense)

</div>


> Index your Ecto schemas directly into Typesense!

## Documentation

Documentation can be found at [https://hexdocs.pm/ecto_typesense](https://hexdocs.pm/ecto_typesense).

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
