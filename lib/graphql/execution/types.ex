defmodule GraphQL.Execution.Types do
  def unwrap_type(type) when is_atom(type), do: type
  def unwrap_type(type), do: type.type
end
