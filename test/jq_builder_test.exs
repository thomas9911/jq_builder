defmodule JqBuilderTest do
  use ExUnit.Case
  doctest JqBuilder

  test "pick" do
    assert ~s{.["foo"] | .["bar"]} ==
             JqBuilder.builder()
             |> JqBuilder.pick("foo")
             |> JqBuilder.pick("bar")
             |> JqBuilder.build()
  end

  @tag :tmp_dir
  test "pick works", %{tmp_dir: tmp_dir} do
    filter =
      JqBuilder.builder()
      |> JqBuilder.pick("foo", true)
      |> JqBuilder.pick("bar")
      |> JqBuilder.build()

    assert {:ok, 1} = TestHelper.run_jq_inline(~s|{"foo": {"bar": 1}}|, filter, tmp_dir)
  end
end
