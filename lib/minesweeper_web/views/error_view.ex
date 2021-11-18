defmodule MinesweeperWeb.ErrorView do
  use MinesweeperWeb, :view

  alias Ecto.Changeset

  import Phoenix.Controller, only: [status_message_from_template: 1]
  import Phoenix.View, only: [render: 3]

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
    render("generic.html", Map.put(assigns, :message, "Page not found"))
  end

  # By default, Phoenix returns the status message from the template name. For
  # example, "404.html" becomes "Not Found".
  def template_not_found(template, %{conn: conn} = assigns) do
    render(__MODULE__, "generic.html",
      conn: conn,
      message: Map.get(assigns, :message, status_message_from_template(template))
    )
  end
end
