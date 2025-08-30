defmodule JqBuilder.Macro do
  @input_name :input
  @input_ctx nil
  @input_var Macro.var(@input_name, @input_ctx)

  defmacro block(code) do
    updated_block = add_input_var(code)

    walk(updated_block, [])
    |> Enum.reverse()
    |> :erlang.iolist_to_binary()
  end

  defp add_input_var(do: {:__block__, ctx, rows}) do
    [
      do:
        {:__block__, ctx,
         [
           {:=, [], [Macro.var(@input_name, nil), nil]}
         ] ++ rows}
    ]
  end

  defp add_input_var(do: inline) do
    [
      do:
        {:__block__, [],
         [
           {:=, [], [@input_var, nil]}
         ] ++ [inline]}
    ]
  end

  defp walk([do: {:__block__, _, rows}], acc) do
    walk(rows, acc)
  end

  defp walk(rows, acc) when is_list(rows) do
    Enum.reduce(rows, acc, &walk/2)
  end

  defp walk({:=, _, [@input_var, nil]}, acc) do
    acc
  end

  defp walk({:if, _, [condition, inner_if]}, acc) do
    formatted_condition = walk(condition, []) |> Enum.reverse()
    formatted_then = walk(inner_if[:do], []) |> Enum.reverse()
    formatted_else = walk(inner_if[:else], []) |> Enum.reverse()

    ["if (#{formatted_condition}) then #{formatted_then} else #{formatted_else} end" | acc]
  end

  defp walk({{:., _, [Access, :get]}, _, [{@input_name, _, @input_ctx}, key]}, acc) do
    # get key (input[key])
    ["\"#{key}\"", "." | acc]
  end

  defp walk(@input_var, acc) do
    ["." | acc]
  end

  defp walk({:=, _, [assignment, value]}, acc) do
    [field | formatted_assignment] = walk(assignment, []) |> Enum.reverse()

    ["{ #{Enum.reverse(formatted_assignment)}: #{encode_value(value)} }", "+ ", "#{field} "] ++
      acc
  end

  defp walk({@input_name, _, @input_ctx}, acc) do
    [". " | acc]
  end

  defp walk(nil, acc) do
    acc
  end

  defp encode_value(value) when is_binary(value), do: inspect(value)
  defp encode_value(value), do: value
end
