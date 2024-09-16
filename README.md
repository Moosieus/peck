# Peck
I've been working on bring support for [ParadeDB](https://www.paradedb.com/) to Ecto over the past few weeks, which I think suits this prompt rather nicely.

ParadeDB is a set of Postgres extensions that allows developers to perform search and analytical workloads without the need of external services like ElasticSearch or ClickHouse. I've been working on bringing support for ParadeDB's search queries to Ecto, which I'd like to demonstrate.

Perhaps we're interested in getting some coffee from a barista truck. Perhaps some folks would prefer a vegan option, but don't strictly require it. Therefore we would like to query food trucks for the term "coffee" and optionally "vegan", ordering results that mention both first:

```elixir
from(
  f in FoodTruck,
  search: boolean(
    must: parse(f, "food_items:coffee"),
    should: parse(f, "food_items:vegan")
  )
) |> Repo.all()
```

ParadeDB provides fully featured BM25 search index via [tantivy](https://github.com/quickwit-oss/tantivy), making the solution extremely accessible.

I personally know someone with severe food allergies who must be selective about eating out. A search query like this might suit them:
```elixir
from(
  f in FoodTruck,
  search: boolean(
    must: parse(f, "food_items:chicken"),
    must_not: parse(f, "food_items:nuts OR food_items:shellfish OR food_items:milk OR food_items:egg")
  ),
  select: %{name: f.applicant, location: f.location_description, food: f.food_items}
) |> Repo.all()
```

With this second query, I've added a `select:` expression to demonstrate that the search index results are plain SQL rows, which we can use fluently with the rest of Ecto.

## Conclusion
There's more I'd like to show, but I'll have to keep this brief for the sake of time.
* Because ParadeDB utilizes Tantivy under the hood, it scales especially well with complex queries and large amounts of data. The query times are also optimized for fast retrieval, such as as-you-type completions.

* With traditional search engines, care must be taken to `JOIN` and load all the data te search engine should return in development. With this solution, a query like this would be more than possible (assuming we had a table of police districts):
  ```elixir
  from(
    f in FoodTruck,
    search: parse(f, "food_items:coffee AND food_items:donuts"),
    join: pd in assoc(f, :police_district),
    preload: [police_district: pd]
  )
  ```

The full list of available search queries can be listed in IEx with `exports Ecto.Query.SearchAPI`, and the ParadeDB docs are available at https://docs.paradedb.com/api-reference/full-text/bm25.

I'm actively working on bringing support for more of ParadeDB's features such as hybrid full-text/semantic search, facets, aggregations, and more.

## Local Test Setup
* Create a `.env` file from `.env.example`.
* Start ParadeDB: `docker compose up`/`lazydocker + x + up`/etc.
* Setup the database: `mix setup`.
* Import the data dump: 
  * `mix import_food_trucks "./priv/Mobile_Food_Facility_Permit.csv"`.
  * pw: `postgres`
* Try stuff out with: `iex -S mix`!
  ```elixir
  from(f in FoodTruck, search: parse(f, "food_items:mac")) |> Repo.all()
  ```
 
## Misc stuff
* Connecting to the database: `psql -h 127.0.0.1 -U postgres peck_dev`.
* `.iex.exs` will load helpful aliases on startup.
