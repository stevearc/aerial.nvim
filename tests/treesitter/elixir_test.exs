defmodule Example.Module do
  @moduledoc """
  Module documentation
  """
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
  @constant 5
  defstruct name: nil, age: nil
end

defprotocol Example.Protocol do
  @doc """
  function documentation
  """
  @doc since: "1.3.0"
  @spec public_function_head(t, atom()) :: boolean
  def public_function_head(target, opt)
end

defimpl Example.Protocol, for: Map do
  @spec public_function_head(Map.t(), atom()) :: boolean
  def public_function_head(target, opt) do
    true
  end
end

# https://hexdocs.pm/ex_unit/ExUnit.Case.html#describe/2-examples
defmodule StringTest do
  use ExUnit.Case, async: true

  describe "String.capitalize/1" do
    setup do
      # setup code
    end

    test "first grapheme is in uppercase" do
      assert String.capitalize("hello") == "Hello"
    end

    test "converts remaining graphemes to lowercase" do
      assert String.capitalize("HELLO") == "Hello"
    end
  end
end

def parameterless_function do
end
