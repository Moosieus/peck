import Config

# Configure your database
config :peck, Peck.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "peck_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
