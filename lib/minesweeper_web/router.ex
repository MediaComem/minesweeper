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

    get "/", Home.HomeController, :index
  end

  # REST API
  scope "/api", MinesweeperWeb do
    pipe_through :api

    post "/games", Game.GameController, :create
    get "/games/:id", Game.GameController, :show
    post "/games/:id/moves", Game.GameController, :play
  end
end
