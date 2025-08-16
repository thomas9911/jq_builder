defmodule JqBuilder do
  @moduledoc """
  Documentation for `JqBuilder`.
  """

  defstruct [:fields]

  def new, do: builder()

  def builder do
    %__MODULE__{fields: []}
  end

  def pick(%__MODULE__{fields: fields} = builder, field, optional \\ false) do
    %{builder | fields: [add_optional(".[\"#{field}\"]", optional) | fields]}
  end

  def at(%__MODULE__{fields: fields} = builder, index) do
    %{builder | fields: [".[#{index}]" | fields]}
  end

  def range(%__MODULE__{fields: fields} = builder, from, to) do
    %{builder | fields: [".[#{from}:#{to}]" | fields]}
  end

  def all(%__MODULE__{fields: fields} = builder, optional \\ false) do
    %{builder | fields: [add_optional(".[]", optional) | fields]}
  end

  defp add_optional(filter, false), do: filter
  defp add_optional(filter, true), do: filter <> "?"

  def build(%__MODULE__{fields: []}), do: "."

  def build(%__MODULE__{fields: fields}) do
    fields
    |> Enum.reverse()
    |> Enum.join(" | ")
  end
end
