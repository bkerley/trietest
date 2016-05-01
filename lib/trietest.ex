defmodule Trietest do
  defstruct end_word: false, children: %{}

  def add_word(%Trietest{} = t, some_word) when is_binary(some_word) do
    add_word(t, String.to_char_list(some_word))
  end

  def add_word(%Trietest{} = t, [] = _end_of_word) do
    struct(t, end_word: true)
  end

  def add_word(%Trietest{children: children} = here,
               [first_char | remain] = _word) do
    found_child = children[first_char]
    subtrie = case found_child do
                nil -> %Trietest{}
                actual_child -> actual_child
              end

    updated_subtrie = add_word(subtrie, remain)
    updated_children = Map.put(children, first_char, updated_subtrie)
    struct(here, children: updated_children)
  end

  def include_word(%Trietest{} = t, some_word) when is_binary(some_word) do
    include_word(t, String.to_char_list(some_word))
  end

  def include_word(%Trietest{end_word: end_word}, [] = _end_of_word) do
    end_word
  end

  def include_word(%Trietest{children: children},
                   [first_char | remain] = _word) do

    found_child = children[first_char]
    case found_child do
      nil -> false
      some_trie ->
        include_word(some_trie, remain)
    end
  end

  def to_dot(%Trietest{} = t) do
    inner = to_dot(t, "n")
    "digraph { #{inner} }"
  end

  def to_dot(%Trietest{children: ch, end_word: false}, "n") when %{} == ch do
    "n[label=\"root\"];"
  end

  def to_dot(%Trietest{children: ch, end_word: false},
             name_pfx) when %{} == ch do
    last_letter = name_pfx
    |> IO.chardata_to_string
    |> String.last
    "#{name_pfx}[label=\"#{last_letter}\"];"
  end

  def to_dot(%Trietest{children: ch, end_word: true},
             name_pfx) do
    ~s(
      #{to_dot(%Trietest{children: ch}, name_pfx)}
      #{name_pfx}[penwidth=2];
    )
  end

  def to_dot(%Trietest{children: children, end_word: false}, name_pfx) do
    child_node_names = children
    |> Map.keys
    |> Enum.map(fn(k) -> "#{name_pfx}#{IO.chardata_to_string([k])}" end)

    child_dots = children
    |> Enum.map(fn({k, v}) ->
      child_name = "#{name_pfx}#{IO.chardata_to_string([k])}"
      to_dot(v, child_name)
    end)

    last_letter = case name_pfx do
                    "n" -> "root"
                    other -> other
                      |> IO.chardata_to_string
                      |> String.last
                  end

    case map_size(children) do
      1 ->
        [name] = child_node_names
        ~s(
          #{name_pfx} -> #{name};
          #{child_dots}
          #{name_pfx}[label="#{last_letter}"];
        )
      _ ->
        ~s(
          #{name_pfx} -> {#{child_node_names |> Enum.join(" ")}};
          #{child_dots}
          #{name_pfx}[label="#{last_letter}"]
        )
    end
  end
end
