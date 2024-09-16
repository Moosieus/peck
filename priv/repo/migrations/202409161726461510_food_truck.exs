defmodule Peck.Repo.Migrations.CreateFoodTrucks do
  use Ecto.Migration

  def up do
    create table(:food_trucks) do
      add :location_id, :integer
      add :applicant, :text
      add :facility_type, :text
      add :cnn, :integer
      add :location_description, :text
      add :address, :text
      add :block_lot, :text
      add :block, :text
      add :lot, :text
      add :permit, :text
      add :status, :text
      add :food_items, :text
      add :x, :text # noindex
      add :y, :text # noindex
      add :latitude, :text # noindex
      add :longitude, :text # noindex
      add :schedule, :text # noindex
      add :dayshours, :text # noindex
      add :noi_sent, :text # noindex
      add :approved, :naive_datetime
      add :received, :date
      add :prior_permit, :boolean
      add :expiration_date, :date
      add :location, :text # noindex
      add :fire_prevention_districts, :integer
      add :police_districts, :integer
      add :supervisor_districts, :integer
      add :zip_codes, :integer
      add :neighborhoods_old, :integer
    end

    execute("""
    CALL paradedb.create_bm25(
      index_name => 'food_trucks_search_idx',
      schema_name => 'public',
      table_name => 'food_trucks',
      key_field => 'id',
      text_fields => paradedb.field(
        name => 'applicant'
      ) || paradedb.field(
        name => 'location_description'
      ) || paradedb.field(
        name => 'address'
      ) || paradedb.field(
        name => 'block_lot'
      ) || paradedb.field(
        name => 'block'
      ) || paradedb.field(
        name => 'lot'
      ) || paradedb.field(
        name => 'permit'
      ) || paradedb.field(
        name => 'status', tokenizer => paradedb.tokenizer('raw')
      ) || paradedb.field(
        name => 'food_items', tokenizer => paradedb.tokenizer('stem', language => 'English')
      ),
      datetime_fields => paradedb.field(
        name => 'received'
      ) || paradedb.field(
        name => 'approved'
      ) || paradedb.field(
        name => 'expiration_date'
      ),
      numeric_fields => paradedb.field(
        name => 'location_id'
      ) || paradedb.field(
        name => 'cnn'
      ) || paradedb.field(
        name => 'fire_prevention_districts'
      ) || paradedb.field(
        name => 'police_districts'
      ) || paradedb.field(
        name => 'supervisor_districts'
      ) || paradedb.field(
        name => 'zip_codes'
      ) || paradedb.field(
        name => 'neighborhoods_old'
      ),
      boolean_fields => paradedb.field(
        name => 'prior_permit'
      )
    )
    """)
  end

  def down do
    execute("""
    CALL paradedb.drop_bm25(
      index_name => 'food_trucks_search_idx',
      schema_name => 'public'
    )
    """)

    drop table(:food_trucks)
  end
end
