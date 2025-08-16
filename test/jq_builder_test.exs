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
    file = Path.join(tmp_dir, "data.json")
    File.write!(file, ~s|{"foo": {"bar": 1}}|)

    filter =
      JqBuilder.builder()
      |> JqBuilder.pick("foo", true)
      |> JqBuilder.pick("bar")
      |> JqBuilder.build()

    assert {:ok, 1} = run_jq(file, filter)
  end

  defp run_jq(json_file, filter) do
    case System.cmd("jq", [filter, json_file], stderr_to_stdout: true) do
      {data, 0} -> {:ok, JSON.decode!(data)}
      {error, _error_code} -> {:error, error}
    end
  end
end
