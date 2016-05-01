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
end
