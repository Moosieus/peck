defmodule Peck.Repo do
  use Ecto.Repo,
    otp_app: :peck,
    adapter: Ecto.Adapters.Postgres
end
