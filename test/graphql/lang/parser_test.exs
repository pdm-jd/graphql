defmodule GraphQL.Lang.Parser.ParserTest do
  use ExUnit.Case, async: true

  import ExUnit.TestHelpers

  test "Report error with message" do
    assert_parse(
      "a",
      %{
        errors: [
          %{"message" => "GraphQL: syntax error before: \"a\" on line 1", "line_number" => 1}
        ]
      },
      :error
    )

    assert_parse(
      "a }",
      %{
        errors: [
          %{"message" => "GraphQL: syntax error before: \"a\" on line 1", "line_number" => 1}
        ]
      },
      :error
    )

    # assert_parse "", %{errors: [%{"message" => "GraphQL: syntax error before:  on line 1", "line_number" => 1}]}, :error
    assert_parse(
      "{}",
      %{
        errors: [
          %{"message" => "GraphQL: syntax error before: '}' on line 1", "line_number" => 1}
        ]
      },
      :error
    )
  end

  test "Handle unicode in string values" do
    assert_parse(~S[{ f(a: "é")}], %{
      definitions: [
        %{
          kind: :OperationDefinition,
          loc: %{start: 0},
          operation: :query,
          selectionSet: %{
            kind: :SelectionSet,
            loc: %{start: 0},
            selections: [
              %{
                arguments: [
                  %{
                    kind: :Argument,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "a"},
                    value: %{kind: :StringValue, loc: %{start: 0}, value: "é"}
                  }
                ],
                kind: :Field,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "f"}
              }
            ]
          }
        }
      ],
      kind: :Document,
      loc: %{start: 0}
    })

    assert_parse(~S[{ f(a: "–")}], %{
      definitions: [
        %{
          kind: :OperationDefinition,
          loc: %{start: 0},
          operation: :query,
          selectionSet: %{
            kind: :SelectionSet,
            loc: %{start: 0},
            selections: [
              %{
                arguments: [
                  %{
                    kind: :Argument,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "a"},
                    value: %{kind: :StringValue, loc: %{start: 0}, value: "–"}
                  }
                ],
                kind: :Field,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "f"}
              }
            ]
          }
        }
      ],
      kind: :Document,
      loc: %{start: 0}
    })
  end

  test "simple selection set" do
    assert_parse(
      "{ hero }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "hero"}
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "multiple definitions" do
    assert_parse(
      "{ hero } { ship }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "hero"}
                }
              ]
            }
          },
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "ship"}
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "aliased selection set" do
    assert_parse(
      "{alias: hero}",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  alias: %{kind: :Name, loc: %{start: 0}, value: "alias"},
                  name: %{kind: :Name, loc: %{start: 0}, value: "hero"}
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "multiple selection set" do
    assert_parse(
      "{ id firstName lastName }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "id"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "firstName"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "lastName"}
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "nested selection set" do
    assert_parse(
      "{ user { name } }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "user"},
                  selectionSet: %{
                    kind: :SelectionSet,
                    loc: %{start: 0},
                    selections: [
                      %{
                        kind: :Field,
                        loc: %{start: 0},
                        name: %{kind: :Name, loc: %{start: 0}, value: "name"}
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "named query with nested selection set" do
    assert_parse(
      "query myQuery { user { name } }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "myQuery"},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "user"},
                  selectionSet: %{
                    kind: :SelectionSet,
                    loc: %{start: 0},
                    selections: [
                      %{
                        kind: :Field,
                        loc: %{start: 0},
                        name: %{kind: :Name, loc: %{start: 0}, value: "name"}
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "named mutation with nested selection set" do
    assert_parse(
      "mutation myMutation { user { name } }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "myMutation"},
            operation: :mutation,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "user"},
                  selectionSet: %{
                    kind: :SelectionSet,
                    loc: %{start: 0},
                    selections: [
                      %{
                        kind: :Field,
                        loc: %{start: 0},
                        name: %{kind: :Name, loc: %{start: 0}, value: "name"}
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "nested selection set with arguments" do
    assert_parse(
      "{ user(id: 4) { name ( thing : \"abc\" ) } }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "user"},
                  arguments: [
                    %{
                      kind: :Argument,
                      loc: %{start: 0},
                      name: %{kind: :Name, loc: %{start: 0}, value: "id"},
                      value: %{kind: :IntValue, loc: %{start: 0}, value: 4}
                    }
                  ],
                  selectionSet: %{
                    kind: :SelectionSet,
                    loc: %{start: 0},
                    selections: [
                      %{
                        kind: :Field,
                        loc: %{start: 0},
                        name: %{kind: :Name, loc: %{start: 0}, value: "name"},
                        arguments: [
                          %{
                            kind: :Argument,
                            loc: %{start: 0},
                            name: %{kind: :Name, loc: %{start: 0}, value: "thing"},
                            value: %{kind: :StringValue, loc: %{start: 0}, value: "abc"}
                          }
                        ]
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "aliased nested selection set with arguments" do
    assert_parse(
      "{ alias: user(id: 4) { alias2 : name ( thing : \"abc\" ) } }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "user"},
                  alias: %{kind: :Name, loc: %{start: 0}, value: "alias"},
                  arguments: [
                    %{
                      kind: :Argument,
                      loc: %{start: 0},
                      name: %{kind: :Name, loc: %{start: 0}, value: "id"},
                      value: %{kind: :IntValue, loc: %{start: 0}, value: 4}
                    }
                  ],
                  selectionSet: %{
                    kind: :SelectionSet,
                    loc: %{start: 0},
                    selections: [
                      %{
                        kind: :Field,
                        loc: %{start: 0},
                        name: %{kind: :Name, loc: %{start: 0}, value: "name"},
                        alias: %{kind: :Name, loc: %{start: 0}, value: "alias2"},
                        arguments: [
                          %{
                            kind: :Argument,
                            loc: %{start: 0},
                            name: %{kind: :Name, loc: %{start: 0}, value: "thing"},
                            value: %{kind: :StringValue, loc: %{start: 0}, value: "abc"}
                          }
                        ]
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "FragmentSpread" do
    assert_parse(
      "query myQuery { ...fragSpread }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "myQuery"},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :FragmentSpread,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "fragSpread"}
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "FragmentSpread with Directive" do
    assert_parse(
      "query myQuery { ...fragSpread @include(if: true) }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "myQuery"},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :FragmentSpread,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "fragSpread"},
                  directives: [
                    %{
                      kind: :Directive,
                      loc: %{start: 0},
                      name: %{kind: :Name, loc: %{start: 0}, value: "include"},
                      arguments: [
                        %{
                          kind: :Argument,
                          loc: %{start: 0},
                          name: %{kind: :Name, loc: %{start: 0}, value: "if"},
                          value: %{kind: :BooleanValue, loc: %{start: 0}, value: true}
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "VariableDefinition with DefaultValue" do
    assert_parse(
      "query myQuery($size: Int = 10) { id }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "myQuery"},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "id"}
                }
              ]
            },
            variableDefinitions: [
              %{
                kind: :VariableDefinition,
                loc: %{start: 0},
                defaultValue: %{kind: :IntValue, loc: %{start: 0}, value: 10},
                type: %{
                  kind: :NamedType,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "Int"}
                },
                variable: %{
                  kind: :Variable,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "size"}
                }
              }
            ]
          }
        ]
      }
    )
  end

  test "Multiple VariableDefinition with DefaultValue (NonNullType, ListType, Variable)" do
    assert_parse(
      "query myQuery($x: Int! = 7, $y: [Int], $z: Some = $var) { id }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "myQuery"},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "id"}
                }
              ]
            },
            variableDefinitions: [
              %{
                kind: :VariableDefinition,
                loc: %{start: 0},
                defaultValue: %{kind: :IntValue, loc: %{start: 0}, value: 7},
                type: %{
                  kind: :NonNullType,
                  loc: %{start: 0},
                  type: %{
                    kind: :NamedType,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "Int"}
                  }
                },
                variable: %{
                  kind: :Variable,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "x"}
                }
              },
              %{
                kind: :VariableDefinition,
                loc: %{start: 0},
                type: %{
                  kind: :ListType,
                  loc: %{start: 0},
                  type: %{
                    kind: :NamedType,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "Int"}
                  }
                },
                variable: %{
                  kind: :Variable,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "y"}
                }
              },
              %{
                defaultValue: %{
                  kind: :Variable,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "var"}
                },
                kind: :VariableDefinition,
                loc: %{start: 0},
                type: %{
                  kind: :NamedType,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "Some"}
                },
                variable: %{
                  kind: :Variable,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "z"}
                }
              }
            ]
          }
        ]
      }
    )
  end

  test "Multiple VariableDefinition with DefaultValue (EnumValue ListValue) and Directives" do
    assert_parse(
      "query myQuery($x: Int! = ENUM, $y: [Int] = [1, 2]) @directive(num: 1.23, a: {b: 1, c: 2}) { id }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "myQuery"},
            operation: :query,
            directives: [
              %{
                kind: :Directive,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "directive"},
                arguments: [
                  %{
                    kind: :Argument,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "num"},
                    value: %{kind: :FloatValue, loc: %{start: 0}, value: 1.23}
                  },
                  %{
                    kind: :Argument,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "a"},
                    value: %{
                      kind: :ObjectValue,
                      loc: %{start: 0},
                      fields: [
                        %{
                          kind: :ObjectField,
                          loc: %{start: 0},
                          name: %{kind: :Name, loc: %{start: 0}, value: "b"},
                          value: %{kind: :IntValue, loc: %{start: 0}, value: 1}
                        },
                        %{
                          kind: :ObjectField,
                          loc: %{start: 0},
                          name: %{kind: :Name, loc: %{start: 0}, value: "c"},
                          value: %{kind: :IntValue, loc: %{start: 0}, value: 2}
                        }
                      ]
                    }
                  }
                ]
              }
            ],
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "id"}
                }
              ]
            },
            variableDefinitions: [
              %{
                defaultValue: %{kind: :EnumValue, loc: %{start: 0}, value: "ENUM"},
                kind: :VariableDefinition,
                loc: %{start: 0},
                type: %{
                  kind: :NonNullType,
                  loc: %{start: 0},
                  type: %{
                    kind: :NamedType,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "Int"}
                  }
                },
                variable: %{
                  kind: :Variable,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "x"}
                }
              },
              %{
                defaultValue: %{
                  kind: :ListValue,
                  loc: %{start: 0},
                  values: [
                    %{kind: :IntValue, loc: %{start: 0}, value: 1},
                    %{kind: :IntValue, loc: %{start: 0}, value: 2}
                  ]
                },
                kind: :VariableDefinition,
                loc: %{start: 0},
                type: %{
                  kind: :ListType,
                  loc: %{start: 0},
                  type: %{
                    kind: :NamedType,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "Int"}
                  }
                },
                variable: %{
                  kind: :Variable,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "y"}
                }
              }
            ]
          }
        ]
      }
    )
  end

  test "FragmentDefinition" do
    assert_parse(
      "fragment friends on User { id }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :FragmentDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "friends"},
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "id"}
                }
              ]
            },
            typeCondition: %{
              kind: :NamedType,
              loc: %{start: 0},
              name: %{kind: :Name, loc: %{start: 0}, value: "User"}
            }
          }
        ]
      }
    )
  end

  test "InlineFragment" do
    assert_parse(
      "{ user { name, ... on Person { age }, ... @include(if: true) { id } } }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "user"},
                  selectionSet: %{
                    kind: :SelectionSet,
                    loc: %{start: 0},
                    selections: [
                      %{
                        kind: :Field,
                        loc: %{start: 0},
                        name: %{kind: :Name, loc: %{start: 0}, value: "name"}
                      },
                      %{
                        kind: :InlineFragment,
                        loc: %{start: 0},
                        selectionSet: %{
                          kind: :SelectionSet,
                          loc: %{start: 0},
                          selections: [
                            %{
                              kind: :Field,
                              loc: %{start: 0},
                              name: %{kind: :Name, loc: %{start: 0}, value: "age"}
                            }
                          ]
                        },
                        typeCondition: %{
                          kind: :NamedType,
                          loc: %{start: 0},
                          name: %{kind: :Name, loc: %{start: 0}, value: "Person"}
                        }
                      },
                      %{
                        directives: [
                          %{
                            arguments: [
                              %{
                                kind: :Argument,
                                loc: %{start: 0},
                                name: %{kind: :Name, loc: %{start: 0}, value: "if"},
                                value: %{kind: :BooleanValue, loc: %{start: 0}, value: true}
                              }
                            ],
                            kind: :Directive,
                            loc: %{start: 0},
                            name: %{kind: :Name, loc: %{start: 0}, value: "include"}
                          }
                        ],
                        kind: :InlineFragment,
                        loc: %{start: 0},
                        selectionSet: %{
                          kind: :SelectionSet,
                          loc: %{start: 0},
                          selections: [
                            %{
                              kind: :Field,
                              loc: %{start: 0},
                              name: %{kind: :Name, loc: %{start: 0}, value: "id"}
                            }
                          ]
                        }
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "ObjectTypeDefinition" do
    assert_parse(
      "type Human implements Character, Entity { id: String! friends: [Character] }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :ObjectTypeDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "Human"},
            fields: [
              %{
                kind: :FieldDefinition,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "id"},
                type: %{
                  kind: :NonNullType,
                  loc: %{start: 0},
                  type: %{
                    kind: :NamedType,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "String"}
                  }
                }
              },
              %{
                kind: :FieldDefinition,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "friends"},
                type: %{
                  kind: :ListType,
                  loc: %{start: 0},
                  type: %{
                    kind: :NamedType,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "Character"}
                  }
                }
              }
            ],
            interfaces: [
              %{
                kind: :NamedType,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "Character"}
              },
              %{
                kind: :NamedType,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "Entity"}
              }
            ]
          }
        ]
      }
    )
  end

  test "ObjectTypeDefinition with Arguments" do
    assert_parse(
      "type Query { hero(episode: Episode): Character human(id: String! name: String): Human }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :ObjectTypeDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "Query"},
            fields: [
              %{
                kind: :FieldDefinition,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "hero"},
                type: %{
                  kind: :NamedType,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "Character"}
                },
                arguments: [
                  %{
                    kind: :InputValueDefinition,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "episode"},
                    type: %{
                      kind: :NamedType,
                      loc: %{start: 0},
                      name: %{kind: :Name, loc: %{start: 0}, value: "Episode"}
                    }
                  }
                ]
              },
              %{
                kind: :FieldDefinition,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "human"},
                type: %{
                  kind: :NamedType,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "Human"}
                },
                arguments: [
                  %{
                    kind: :InputValueDefinition,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "id"},
                    type: %{
                      kind: :NonNullType,
                      loc: %{start: 0},
                      type: %{
                        kind: :NamedType,
                        loc: %{start: 0},
                        name: %{kind: :Name, loc: %{start: 0}, value: "String"}
                      }
                    }
                  },
                  %{
                    kind: :InputValueDefinition,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "name"},
                    type: %{
                      kind: :NamedType,
                      loc: %{start: 0},
                      name: %{kind: :Name, loc: %{start: 0}, value: "String"}
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    )
  end

  test "InterfaceTypeDefinition" do
    assert_parse(
      "interface Node { id: ID }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :InterfaceTypeDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "Node"},
            fields: [
              %{
                kind: :FieldDefinition,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "id"},
                type: %{
                  kind: :NamedType,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "ID"}
                }
              }
            ]
          }
        ]
      }
    )
  end

  test "UnionTypeDefinition" do
    assert_parse(
      "union Actor = User | Business",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :UnionTypeDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "Actor"},
            types: [
              %{
                kind: :NamedType,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "User"}
              },
              %{
                kind: :NamedType,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "Business"}
              }
            ]
          }
        ]
      }
    )
  end

  test "ScalarTypeDefinition" do
    assert_parse(
      "scalar DateTime",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :ScalarTypeDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "DateTime"}
          }
        ]
      }
    )
  end

  test "EnumTypeDefinition" do
    assert_parse(
      "enum Direction { NORTH EAST SOUTH WEST }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :EnumTypeDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "Direction"},
            values: ["NORTH", "EAST", "SOUTH", "WEST"]
          }
        ]
      }
    )
  end

  test "InputObjectTypeDefinition" do
    assert_parse(
      "input Point2D { x: Float y: Float }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :InputObjectTypeDefinition,
            loc: %{start: 0},
            name: %{kind: :Name, loc: %{start: 0}, value: "Point2D"},
            fields: [
              %{
                kind: :InputValueDefinition,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "x"},
                type: %{
                  kind: :NamedType,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "Float"}
                }
              },
              %{
                kind: :InputValueDefinition,
                loc: %{start: 0},
                name: %{kind: :Name, loc: %{start: 0}, value: "y"},
                type: %{
                  kind: :NamedType,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "Float"}
                }
              }
            ]
          }
        ]
      }
    )
  end

  test "TypeExtensionDefinition" do
    assert_parse(
      "extend type Story { isHiddenLocally: Boolean }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :TypeExtensionDefinition,
            loc: %{start: 0},
            definition: %{
              kind: :ObjectTypeDefinition,
              loc: %{start: 0},
              name: %{kind: :Name, loc: %{start: 0}, value: "Story"},
              fields: [
                %{
                  kind: :FieldDefinition,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "isHiddenLocally"},
                  type: %{
                    kind: :NamedType,
                    loc: %{start: 0},
                    name: %{kind: :Name, loc: %{start: 0}, value: "Boolean"}
                  }
                }
              ]
            }
          }
        ]
      }
    )
  end

  test "Use reserved words as fields" do
    assert_parse(
      "{ query mutation fragment on type implements interface union scalar enum input extend null }",
      %{
        kind: :Document,
        loc: %{start: 0},
        definitions: [
          %{
            kind: :OperationDefinition,
            loc: %{start: 0},
            operation: :query,
            selectionSet: %{
              kind: :SelectionSet,
              loc: %{start: 0},
              selections: [
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "query"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "mutation"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "fragment"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "on"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "type"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "implements"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "interface"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "union"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "scalar"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "enum"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "input"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "extend"}
                },
                %{
                  kind: :Field,
                  loc: %{start: 0},
                  name: %{kind: :Name, loc: %{start: 0}, value: "null"}
                }
              ]
            }
          }
        ]
      }
    )
  end
end
