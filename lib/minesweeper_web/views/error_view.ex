defmodule MinesweeperWeb.ErrorView do
  use MinesweeperWeb, :view

  alias Ecto.Changeset

  def render("422.json", %{changeset: %Changeset{errors: errors}}) do
    %{"errors" => Enum.map(errors, &render_error/1)}
  end

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render_error({field, {message, options}}) do
    %{
      "path" => "/#{field}",
      "message" =>
        Regex.replace(~r"%{(\w+)}", message, fn _, key ->
          options |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
    }
  end
end
