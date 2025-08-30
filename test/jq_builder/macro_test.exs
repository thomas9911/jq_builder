defmodule JqBuilder.MacroTest do
  use ExUnit.Case, async: true

  require JqBuilder.Macro

  alias JqBuilder.Macro

  @tag :tmp_dir
  test "if statement", %{tmp_dir: tmp_dir} do
    formatted =
      Macro.block do
        if input["my_key"] do
          input
        else
          input["my_key"] = "1"
        end
      end

    assert "if (.\"my_key\") then .  else . + { \"my_key\": \"1\" } end" == formatted

    assert {:ok, %{"test" => 10, "my_key" => "1"}} ==
             TestHelper.run_jq_inline(%{test: 10}, formatted, tmp_dir)

    assert {:ok, %{"my_key" => 10}} == TestHelper.run_jq_inline(%{my_key: 10}, formatted, tmp_dir)
  end
end
