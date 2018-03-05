defmodule Discourse.Timeline.Entry do
	@moduledoc """
	Hosts functions related to Timeline Entry items
	"""
	
	# creates a timeline entry, returns the generated id
	def create({ timeline_id, timestamp, body, sources, imgurl }) do

		{:ok, dt} = DateTime.from_unix(timestamp)

		ts = %Postgrex.Timestamp{year: dt.year, month: dt.month, day: dt.day, hour: dt.hour, min: dt.minute, sec: dt.second}

		case Postgrex.query(
			Discourse.DB, 
			"INSERT INTO TimelineEntries (timeline, timestamp, body, sources, imgurl) VALUES ($1, $2, $3, $4, $5) RETURNING id",
			[timeline_id, ts, body, sources, imgurl]) do
				{:ok, resp} -> 
					[[id]] = resp.rows
					{:ok, id}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail }}
		end
	end

	# updates timeline entry, returns postgres response
	def update({id, timeline_id, timestamp, body, sources, imgurl}) do

		{:ok, dt} = DateTime.from_unix(timestamp)

		ts = %Postgrex.Timestamp{year: dt.year, month: dt.month, day: dt.day, hour: dt.hour, min: dt.minute, sec: dt.second}

		case Postgrex.query(
			Discourse.DB, 
			"UPDATE TimelineEntries SET (timeline, timestamp, body, sources, imgurl) VALUES ($1, $2, $3, $4, $5) WHERE id=$6",
			[timeline_id, ts, body, sources, imgurl, id]) do
				{:ok, resp} -> {:ok, resp}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	# finds all entries for a timeline id, returns rows as [id, timeline, timestamp, body, sources, imgurl, upvotes, downvotes].
	def from_timeline_id(id) do

		case Postgrex.query(Discourse.DB, "SELECT id, timeline, extract(epoch from timestamp), body, sources, imgurl, upvotes, downvotes FROM TimelineEntries WHERE timeline=$1", [id]) do
			{:ok, resp} -> {:ok, resp.rows}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end
end