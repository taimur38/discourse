defmodule Mix.Tasks.Discourse.Ingest do
	use Mix.Task

	def parse_file(fname) do
		File.read!(fname)
		|> Poison.decode!
	end

	def to_sensible(rows) do 
		Enum.map(rows, fn(row) ->
			{bs, date} = to_date(
					row["gsx$year"]["$t"],
					row["gsx$month"]["$t"],
					row["gsx$day"]["$t"]
				)
			%{
				headline: row["gsx$headline"]["$t"],
				body: row["gsx$text"]["$t"],
				media: row["gsx$media"]["$t"],
				background: row["gsx$background"]["$t"],
				date: date,
				bsDate: bs,
				crap: "#{row["gsx$year"]["$t"]}-#{row["gsx$month"]["$t"]}-#{row["gsx$day"]["$t"]}" 
			}
		end)
	end

	def to_date(nil, nil, nil) do
		{:ok, d} = Date.new(1991, 11, 25)
		{true, d}
	end

	def to_date(year, "", "") do
		case Integer.parse(year) do
			{y, _} -> {false, Date.new(y, 01, 01)}
			:error -> {true, Date.new(2001, 01, 01)}
		end
	end

	def to_date(year, month, day) do

		bs = true

		y = case Integer.parse(year) do
			{y, _} -> 
				bs = false
				y
			:error -> 2001
		end
		m = case Integer.parse(month) do
			{m, _} -> m
			:error -> 1
		end
		d = case Integer.parse(day) do
			{d, _} -> d
			:error -> 1
		end

		case Date.new(y, m, d) do
			{:ok, date} -> {bs, date}
			{:error, _} -> {:ok, date} = Date.new(1991, 11, 25)
				{true, date}
		end
	end

	def run(_) do

		Application.ensure_all_started(:discourse)

		transformed = Path.wildcard("lib/mix/tasks/bootstrap/gdrive/*.json")
		|> Enum.map(&parse_file/1)
		|> Enum.map(fn(data) -> data["feed"]["entry"] end)
		|> Enum.map(&to_sensible/1)


		# load into db
	end

end