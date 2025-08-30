defmodule TestHelper do
  def run_jq_inline(json, filter, tmp_dir) do
    json_file = Path.join(tmp_dir, "data.json")

    json_str =
      if is_binary(json) do
        json
      else
        JSON.encode!(json)
      end

    File.write!(json_file, json_str)

    run_jq(json_file, filter)
  end

  def run_jq(json_file, filter) do
    case System.cmd("jq", [filter, json_file], stderr_to_stdout: true) do
      {data, 0} -> {:ok, JSON.decode!(data)}
      {error, _error_code} -> {:error, error}
    end
  end
end

ExUnit.start()
