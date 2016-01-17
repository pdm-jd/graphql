Code.require_file "../support/star_wars/data.exs", __DIR__
Code.require_file "../support/star_wars/schema.exs", __DIR__

defmodule GraphQL.StarWars.IntrospectionTest do
  use ExUnit.Case, async: true
  import ExUnit.TestHelpers

  test "Allows querying the schema for types" do
    query = """
      query IntrospectionTypeQuery {
          __schema {
            types {
              name
            }
          }
        }
    """
    wanted = %{
      __schema:
        %{types: [
          %{name: "Boolean"},
          %{name: "Character"},
          %{name: "Droid"},
          %{name: "Episode"},
          %{name: "Human"},
          %{name: "Query"},
          %{name: "String"},
          %{name: "__Directive"},
          %{name: "__EnumValue"},
          %{name: "__Field"},
          %{name: "__InputValue"},
          %{name: "__Schema"},
          %{name: "__Type"},
          %{name: "__TypeKind"}
        ]
      }
    }
    assert_execute {query, StarWars.Schema.schema}, wanted
  end

  test "Allows querying the schema for query type" do
    query = """
     query IntrospectionQueryTypeQuery {
      __schema {
        queryType {
          name
        }
      }
    }
    """
    assert_execute {query, StarWars.Schema.schema}, %{__schema: %{queryType: %{name: "Query"}}}
  end

  test "Allows querying the schema for a specific type" do
    query = """
      query IntrospectionDroidTypeQuery {
        __type(name: "Droid") {
          name
        }
      }
    """
    assert_execute {query, StarWars.Schema.schema}, %{__type: %{name: "Droid"}}
  end

  test "Allows querying the schema for an object kind" do
    query = """
      query IntrospectionDroidKindQuery {
        __type(name: "Droid") {
          name
          kind
        }
      }
    """
    assert_execute {query, StarWars.Schema.schema}, %{__type: %{name: "Droid", kind: "OBJECT"}}
  end

  test "Allows querying the schema for an interface kind" do
    query ="""
      query IntrospectionCharacterKindQuery {
        __type(name: "Character") {
          name
          kind
        }
      }
    """
    assert_execute {query, StarWars.Schema.schema}, %{__type: %{name: "Character", kind: "INTERFACE"}}
  end

  test "Allows querying the schema for object fields" do
    query = """
      query IntrospectionDroidFieldsQuery {
        __type(name: "Droid") {
          name
          fields {
            name
            type {
              name
              kind
            }
          }
        }
      }
    """
    wanted = %{__type:
      %{
        fields: [
          %{name: "appears_in", type: %{kind: "LIST", name: nil}},
          %{name: "friends", type: %{kind: "LIST", name: nil}},
          %{name: "id", type: %{kind: "NON_NULL", name: nil}},
          %{name: "name", type: %{kind: "SCALAR", name: "String"}},
          %{name: "primary_function", type: %{kind: "SCALAR", name: "String"}}
        ],
        name: "Droid"
      }
    }
    assert_execute {query, StarWars.Schema.schema}, wanted
  end

  test "Allows querying the schema for nested object fields" do
    query = """
      query IntrospectionDroidNestedFieldsQuery {
        __type(name: "Droid") {
          name
          fields {
            name
            type {
              name
              kind
              of_type {
                name
                kind
              }
            }
          }
        }
      }
    """
    wanted =  %{__type: %{fields: [%{name: "appears_in",
                   type: %{kind: "LIST", name: nil, of_type: %{kind: "ENUM", name: "Episode"}}},
                 %{name: "friends",
                   type: %{kind: "LIST", name: nil, of_type: %{kind: "INTERFACE", name: "Character"}}},
                 %{name: "id", type: %{kind: "NON_NULL", name: nil, of_type: %{kind: "SCALAR", name: "String"}}},
                 %{name: "name", type: %{kind: "SCALAR", name: "String", of_type: nil}},
                 %{name: "primary_function", type: %{kind: "SCALAR", name: "String", of_type: nil}}],
                name: "Droid"}}
    assert_execute {query, StarWars.Schema.schema}, wanted
  end

  @tag :skip # we need to add default_value before this will be complete
  test "Allows querying the schema for field args" do
    query = """
      query IntrospectionQueryTypeQuery {
        __schema {
          queryType {
            fields {
              name
              args {
                name
                description
                type {
                  name
                  kind
                  of_type {
                    name
                    kind
                  }
                }
                default_value
              }
            }
          }
        }
      }
    """
    wanted = %{}

    assert_execute {query, StarWars.Schema.schema}, wanted

  end

  test "Allows querying the schema for documentation" do
    query = """
      query IntrospectionDroidDescriptionQuery {
        __type(name: "Droid") {
          name
          description
        }
      }
    """
    assert_execute {query, StarWars.Schema.schema}, %{__type: %{description: "A mechanical creature in the Star Wars universe", name: "Droid"}}
  end

  test "Can run the full introspection query" do
    assert_execute {GraphQL.Type.Introspection.query, StarWars.Schema.schema}, %{}
  end
end
