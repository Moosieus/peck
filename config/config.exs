import Config

config :peck,
  ecto_repos: [Peck.Repo],
  generators: [timestamp_type: :utc_datetime]

import_config "#{config_env()}.exs"
