defmodule GraphQL.Lang.Lexer.LexerTest do
  use ExUnit.Case, async: true

  def assert_tokens(input, tokens) do
    case :graphql_lexer.string(input) do
      {:ok, output, _} ->
        assert output == tokens

      {:error, {_, :graphql_lexer, output}, _} ->
        assert output == tokens
    end
  end

  # Ignored tokens
  test "WhiteSpace is ignored" do
    # horizontal tab
    assert_tokens(~c"\u0009", [])
    # vertical tab
    assert_tokens(~c"\u000B", [])
    # form feed
    assert_tokens(~c"\u000C", [])
    # space
    assert_tokens(~c"\u0020", [])
    # non-breaking space
    assert_tokens(~c"\u00A0", [])
  end

  test "LineTerminator is ignored" do
    # new line
    assert_tokens(~c"\u000A", [])
    # carriage return
    assert_tokens(~c"\u000D", [])
    # line separator
    assert_tokens(~c"\u2028", [])
    # paragraph separator
    assert_tokens(~c"\u2029", [])
  end

  test "Comment is ignored" do
    assert_tokens(~c"# some comment", [])
  end

  test "Comma is ignored" do
    assert_tokens(~c",", [])
  end

  # Lexical tokens
  test "Punctuator" do
    assert_tokens(~c"!", [{:!, 1}])
    assert_tokens(~c"$", [{:"$", 1}])
    assert_tokens(~c"(", [{:"(", 1}])
    assert_tokens(~c")", [{:")", 1}])
    assert_tokens(~c":", [{:":", 1}])
    assert_tokens(~c"=", [{:=, 1}])
    assert_tokens(~c":", [{:":", 1}])
    assert_tokens(~c"@", [{:@, 1}])
    assert_tokens(~c"[", [{:"[", 1}])
    assert_tokens(~c"]", [{:"]", 1}])
    assert_tokens(~c"{", [{:"{", 1}])
    assert_tokens(~c"}", [{:"}", 1}])
    assert_tokens(~c"|", [{:|, 1}])
    assert_tokens(~c"...", [{:..., 1}])
  end

  test "Name" do
    assert_tokens(~c"_", [{:name, 1, ~c"_"}])
    assert_tokens(~c"a", [{:name, 1, ~c"a"}])
    assert_tokens(~c"Z", [{:name, 1, ~c"Z"}])
    assert_tokens(~c"foo", [{:name, 1, ~c"foo"}])
    assert_tokens(~c"Foo", [{:name, 1, ~c"Foo"}])
    assert_tokens(~c"_foo", [{:name, 1, ~c"_foo"}])
    assert_tokens(~c"foo0", [{:name, 1, ~c"foo0"}])
    assert_tokens(~c"_fu_Ba_QX_2", [{:name, 1, ~c"_fu_Ba_QX_2"}])
  end

  test "Literals" do
    assert_tokens(~c"query", [{:query, 1}])
    assert_tokens(~c"mutation", [{:mutation, 1}])
    assert_tokens(~c"fragment", [{:fragment, 1}])
    assert_tokens(~c"on", [{:on, 1}])
    assert_tokens(~c"type", [{:type, 1}])
  end

  test "IntValue" do
    assert_tokens(~c"0", [{:int_value, 1, ~c"0"}])
    assert_tokens(~c"-0", [{:int_value, 1, ~c"-0"}])
    assert_tokens(~c"-1", [{:int_value, 1, ~c"-1"}])
    assert_tokens(~c"2340", [{:int_value, 1, ~c"2340"}])
    assert_tokens(~c"56789", [{:int_value, 1, ~c"56789"}])
  end

  test "FloatValue" do
    assert_tokens(~c"0.0", [{:float_value, 1, ~c"0.0"}])
    assert_tokens(~c"-0.1", [{:float_value, 1, ~c"-0.1"}])
    assert_tokens(~c"0.1", [{:float_value, 1, ~c"0.1"}])
    assert_tokens(~c"2.340", [{:float_value, 1, ~c"2.340"}])
    assert_tokens(~c"5678.9", [{:float_value, 1, ~c"5678.9"}])
    assert_tokens(~c"1.23e+45", [{:float_value, 1, ~c"1.23e+45"}])
    assert_tokens(~c"1.23E-45", [{:float_value, 1, ~c"1.23E-45"}])
    assert_tokens(~c"0.23E-45", [{:float_value, 1, ~c"0.23E-45"}])
  end

  test "StringValue" do
    assert_tokens(~c"\"\"", [{:string_value, 1, ~c"\"\""}])
    assert_tokens(~c"\"a\"", [{:string_value, 1, ~c"\"a\""}])
    assert_tokens(~c"\"\u000f\"", [{:string_value, 1, ~c"\"\u000f\""}])
    assert_tokens(~c"\"\t\"", [{:string_value, 1, ~c"\"\t\""}])
    assert_tokens(~c"\"\\\"\"", [{:string_value, 1, ~c"\"\\\"\""}])
    assert_tokens(~c"\"a\\n\"", [{:string_value, 1, ~c"\"a\\n\""}])
  end

  test "BooleanValue" do
    assert_tokens(~c"true", [{:boolean_value, 1, ~c"true"}])
    assert_tokens(~c"false", [{:boolean_value, 1, ~c"false"}])
  end

  test "EnumValue" do
    assert_tokens(~c"null", [{:null, 1}])
    assert_tokens(~c"ENUM_VALUE", [{:name, 1, ~c"ENUM_VALUE"}])
    assert_tokens(~c"enum_value", [{:name, 1, ~c"enum_value"}])
  end

  # Sample GraphQL
  test "Simple statement" do
    assert_tokens(~c"{ hero }", [
      {:"{", 1},
      {:name, 1, ~c"hero"},
      {:"}", 1}
    ])
  end

  test "Named query with nested selection set" do
    assert_tokens(~c"query myName { me { name } }", [
      {:query, 1},
      {:name, 1, ~c"myName"},
      {:"{", 1},
      {:name, 1, ~c"me"},
      {:"{", 1},
      {:name, 1, ~c"name"},
      {:"}", 1},
      {:"}", 1}
    ])
  end
end
