defmodule MinesweeperWeb.Errors.ErrorsView do
  use MinesweeperWeb, :html

  embed_templates "./*"

  alias Ecto.Changeset

  import Phoenix.Controller, only: [status_message_from_template: 1]

  def render("404.json", %{resource: resource}) when is_atom(resource) do
    %{
      "code" => "resource_not_found",
      "resource" => Atom.to_string(resource)
    }
  end

  def render("422.json", %{error: error}) when is_map(error) do
    error
  end

  def render("422.json", %{changeset: %Changeset{errors: errors}}) do
    %{
      "code" => "invalid_data",
      "errors" => Enum.map(errors, &render_error/1)
    }
  end

  def render("500.json", _) do
    %{
      "code" => "unexpected_error"
    }
  end

  def render("404.html", assigns) do
    generic_error(Map.put(assigns, :message, "Page not found"))
  end

  # By default, Phoenix returns the status message from the template name. For
  # example, "404.html" becomes "Not Found".
  def render(template, %{conn: conn} = assigns) do
    generic_error(
      conn: conn,
      message: Map.get(assigns, :message, status_message_from_template(template))
    )
  end
end
