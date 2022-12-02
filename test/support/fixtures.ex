defmodule TypesenseTest.Fixtures do
  @moduledoc "Load json files as fixtures."

  def load(name), do: File.read!("test/support/fixtures/#{name}.json")
  def json(name), do: Jason.decode!(load(name))
end
