defmodule MinesweeperWeb.Router do
  use MinesweeperWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Home page
  scope "/", MinesweeperWeb do
    pipe_through :browser

    get "/", HomeController, :index
  end

  # REST API
  scope "/api", MinesweeperWeb do
    pipe_through :api

    post "/games", GameController, :create
    get "/games/:id", GameController, :show
    post "/games/:id/moves", GameController, :play
  end
end
