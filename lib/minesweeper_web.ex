defmodule MinesweeperWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use MinesweeperWeb, :controller
      use MinesweeperWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets css fonts images js favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller,
        namespace: MinesweeperWeb,
        layouts: [html: MinesweeperWeb.Layout.LayoutView]

      import Plug.Conn
      alias MinesweeperWeb.FallbackController

      unquote(verified_routes())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Helpers for error handling
      import MinesweeperWeb.Errors.ErrorsHelpers

      # Routes generation with the ~p sigil
      unquote(verified_routes())

      def put_if(map, key, value, false), do: map
      def put_if(map, key, value, true), do: Map.put(map, key, value)

      def put_non_nil(map, _key, nil), do: map
      def put_non_nil(map, key, value), do: Map.put(map, key, value)
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: MinesweeperWeb.Endpoint,
        router: MinesweeperWeb.Router,
        statics: MinesweeperWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
