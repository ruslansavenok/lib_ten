defmodule LibTenWeb.Router do
  use LibTenWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LibTenWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/library", LibraryController, :index

    scope "/auth" do
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LibTenWeb do
  #   pipe_through :api
  # end
end
