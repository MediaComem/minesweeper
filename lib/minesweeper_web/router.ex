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

    get "/", PageController, :index
  end

  # REST API
  scope "/api", MinesweeperWeb do
    pipe_through :api

    post "/games", GameController, :create
  end
end
