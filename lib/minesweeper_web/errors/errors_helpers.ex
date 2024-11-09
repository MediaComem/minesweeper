defmodule MinesweeperWeb.Errors.ErrorsHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  @doc """
  Serializes an error for the client.
  """
  def render_error({field, {message, options}}) do
    %{
      "path" => "/#{field}",
      "message" => translate_error(message, options)
    }
  end

  @doc """
  Translates an error message.
  """
  def translate_error(message, options) do
    Regex.replace(~r"%{(\w+)}", message, fn _, key ->
      options |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
