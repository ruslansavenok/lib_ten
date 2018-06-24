# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lib_ten,
  ecto_repos: [LibTen.Repo],
  smtp_sender_email: "books@10clouds.com",
  title: "10Books",
  allowed_google_auth_domains: "Set in config.secret.exs"


# Configures the endpoint
config :lib_ten, LibTenWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TmB2X43BwwgU4K5Hkq9f/lVaQmtFGobmRsxJ5ZDhAlogzSenkVR5tfvRRNuFDDIL",
  render_errors: [view: LibTenWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LibTen.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :lib_ten, LibTen.Scheduler,
  jobs: [
    {"0 10 * * *", {
      LibTen.Products.Library, :remind_users_to_return_products, []
    }}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "Set in config.secret.exs",
  client_secret: "Set in config.secret.exs"

# Prevent distributed erlang to be accessible outside of local network
# https://elixirforum.com/t/distillery-node-defaults-should-i-be-concerned-about-security/14836/2
config :kernel,
  inet_dist_use_interface: {127, 0, 0, 1}

# Import config for local development
if File.exists?("config/config.secret.exs") do
  import_config "config.secret.exs"
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
