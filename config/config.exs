# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :twitter_new, TwitterNewWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+FEqmL2JnVNu2D0AGHPda50R97DP6tCP1iRjKlQWqi5k4LBJ0wHecwWRej/AKi8m",
  render_errors: [view: TwitterNewWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TwitterNew.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
