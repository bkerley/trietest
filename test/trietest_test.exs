defmodule TrietestTest do
  use ExUnit.Case
  doctest Trietest

  setup do
    {:ok, words: ~w{add addition adam additive ada ayyy lmao}}
  end

  test "single character" do
    trie = %Trietest{}
    |> Trietest.add_word('a')

    assert %Trietest{children: %{97 => %Trietest{end_word: true}}} == trie

    assert Trietest.include_word(trie, 'a')

    refute Trietest.include_word(trie, 'x')
    refute Trietest.include_word(trie, 'aaa')
  end

  test "two words, different prefix" do
    trie = %Trietest{}
    |> Trietest.add_word('ab')
    |> Trietest.add_word('aa')

    assert %Trietest{
      children: %{97 =>
                   %Trietest{
                     children: %{97 => %Trietest{end_word: true},
                                 98 => %Trietest{end_word: true}},
                     end_word: false}},
      end_word: false} == trie

    same_trie = %Trietest{}
    |> Trietest.add_word('aa')
    |> Trietest.add_word('ab')

    assert trie == same_trie

    assert Trietest.include_word(trie, 'ab')
    assert Trietest.include_word(trie, 'aa')

    refute Trietest.include_word(trie, 'a')
  end

  test "trie", %{words: words} do
    trie = words
    |> Enum.reduce(%Trietest{}, fn(w, t) -> Trietest.add_word(t, w) end)

    words
    |> Enum.each(fn(w) ->
      assert(Trietest.include_word(trie, w),
             "Expected to include #{w}")
    end)
  end
end
