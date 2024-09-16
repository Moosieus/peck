defmodule Peck.FoodTruck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_trucks" do
    field(:location_id, :integer)
    field(:applicant, :string)
    field(:facility_type, Ecto.Enum, values: [:truck, :push_cart])
    field(:cnn, :integer)
    field(:location_description, :string)
    field(:address, :string)
    field(:block_lot, :string)
    field(:block, :string)
    field(:lot, :string)
    field(:permit, :string)
    field(:status, Ecto.Enum, values: [:approved, :expired, :issued, :requested, :suspend])
    field(:food_items, :string)
    field(:x, :string)
    field(:y, :string)
    field(:latitude, :string)
    field(:longitude, :string)
    field(:schedule, :string)
    field(:dayshours, :string)
    field(:noi_sent, :string)
    field(:approved, :naive_datetime)
    field(:received, :date)
    field(:prior_permit, :boolean)
    field(:expiration_date, :date)
    field(:location, :string)
    field(:fire_prevention_districts, :integer)
    field(:police_districts, :integer)
    field(:supervisor_districts, :integer)
    field(:zip_codes, :integer)
    field(:neighborhoods_old, :integer)
  end

  def import_changeset(import_attrs) do
    %__MODULE__{}
    |> cast(import_attrs, [
      :location_id,
      :applicant,
      :cnn,
      :location_description,
      :address,
      :block_lot,
      :block,
      :lot,
      :permit,
      :food_items,
      :x,
      :y,
      :latitude,
      :longitude,
      :schedule,
      :dayshours,
      :noi_sent,
      :prior_permit,
      :location,
      :fire_prevention_districts,
      :police_districts,
      :supervisor_districts,
      :zip_codes,
      :neighborhoods_old
    ])
    |> convert_status()
    |> convert_facility_type()
    |> convert_received()
    |> convert_mdY_his_A_to_date(:approved)
    |> convert_mdY_his_A_to_date(:expiration_date)
    |> validate_required([
      :location_id,
      :applicant,
      :cnn,
      :address,
      :permit,
      :latitude,
      :longitude,
      :schedule,
      :prior_permit,
      :location
    ])
  end

  defp convert_status(changeset) do
    case fetch_field!(changeset, :status) do
      "APPROVED" -> put_change(changeset, :status, :approved)
      "EXPIRED" -> put_change(changeset, :status, :expired)
      "ISSUED" -> put_change(changeset, :status, :issued)
      "REQUESTED" -> put_change(changeset, :status, :requested)
      "SUSPEND" -> put_change(changeset, :status, :suspend)
      _ -> put_change(changeset, :status, nil)
    end
  end

  defp convert_facility_type(changeset) do
    case fetch_field!(changeset, :facility_type) do
      "Push Cart" -> put_change(changeset, :facility_type, :push_cart)
      "Truck" -> put_change(changeset, :facility_type, :truck)
      _ -> put_change(changeset, :facility_type, nil)
    end
  end

  defp convert_received(changeset) do
    case fetch_field!(changeset, :received) do
      <<y::bytes-size(4), m::bytes-size(2), d::bytes-size(2), _::bytes>> ->
        put_change(changeset, :received, Date.from_iso8601!("#{y}-#{m}-#{d}"))
      _ ->
        put_change(changeset, :received, nil)
    end
  end

  defp convert_mdY_his_A_to_date(changeset, key) do
    case fetch_field!(changeset, key) do
      <<d::bytes-size(2), "/", m::bytes-size(2), "/", y::bytes-size(4), _::bytes>> ->
        put_change(changeset, key, Date.from_iso8601!("#{y}-#{m}-#{d}"))
      _ ->
        put_change(changeset, key, nil)
    end
  end
end
