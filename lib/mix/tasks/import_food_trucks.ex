defmodule Mix.Tasks.ImportFoodTrucks do
  @moduledoc """
  Imports food truck data from DataSF's Mobile Food Facility Permit dataset, verifying the imported
  data comports with the existing schema and expectations.
  """
  @shortdoc "Imports food truck data from DataSF's MFFP dataset."

  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSV
  alias Peck.Repo
  alias Peck.FoodTruck
  alias Ecto.Changeset

  @impl Mix.Task
  def run([csv_path] = _args) do
    Application.ensure_all_started(:peck)

    changesets = changeset_stream(csv_path)

    changesets
    |> Enum.reduce([], &acc_invalid/2)
    |> maybe_log_errors_and_exit()

    Repo.transaction(fn ->
      changesets
      |> Stream.each(&Repo.insert!/1)
      |> Stream.run()
    end)
  end

  def changeset_stream(csv_path) when is_binary(csv_path) do
    file_stream =
      csv_path
      |> Path.expand()
      |> File.stream!()

    # [header_row] = Enum.take(file_stream, 1)
    #
    # convert headers to atoms
    # fields = (
    #   header_row
    #   |> String.trim()
    #   |> String.downcase()
    #   |> String.replace(" ", "_")
    #   |> String.replace(["(", ")"], "")
    #   |> String.split(",")
    #   |> Enum.map(&String.to_atom/1)
    # )

    fields = [
      :location_id,
      :applicant,
      :facility_type,
      :cnn,
      :location_description,
      :address,
      :block_lot,
      :block,
      :lot,
      :permit,
      :status,
      :food_items,
      :x,
      :y,
      :latitude,
      :longitude,
      :schedule,
      :days_hours,
      :noi_sent,
      :approved,
      :received,
      :prior_permit,
      :expiration_date,
      :location,
      :fire_prevention_districts,
      :police_districts,
      :supervisor_districts,
      :zip_codes,
      :neighborhoods_old
    ]

    file_stream
    |> CSV.parse_stream(skip_headers: true)
    |> Stream.map(fn row -> Enum.zip(fields, row) |> Map.new() end)
    |> Enum.to_list()
    |> Stream.map(fn map ->
      FoodTruck.import_changeset(map)
    end)
  end

  defp maybe_log_errors_and_exit([]), do: :noop

  defp maybe_log_errors_and_exit(errors) do
    errors
    |> Stream.each(fn changeset ->
      errors = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)

      for {field, msg} <- errors, do: IO.puts("Error: field #{field} #{msg}")
    end)
    |> Stream.run()

    exit({:shutdown, 1})
  end

  defp acc_invalid(%Changeset{valid?: true}, acc), do: acc
  defp acc_invalid(%Changeset{valid?: false} = changeset, acc), do: [changeset | acc]

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
