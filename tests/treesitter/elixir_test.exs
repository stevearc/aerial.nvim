defmodule Example.Module do
  @module_attribute :value

  def public_function() do
  end

  defp private_function() do
  end

  defguard public_guard(x) when is_atom(x)

  defguard private_guard(x) when is_atom(x)
 
  defmacro public_macro() do
  end

  defmacrop private_macro() do
  end
end

defmodule Example.Behaviour do
  @callback example_function(atom()) :: atom()
end

defmodule Example.Struct do
  defstruct name: nil, age: nil
end

defprotocol Example.Protocol do
  @spec public_function_head(t, atom()) :: boolean
  def public_function_head(target, opt)
end

defimpl Example.Protocol, for: Map do
  @spec public_function_head(Map.t(), atom()) :: boolean
  def public_function_head(target, opt) do
    true
  end
end
