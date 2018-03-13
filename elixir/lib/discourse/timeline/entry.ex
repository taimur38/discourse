defmodule Discourse.Timeline.Entry do
	@moduledoc """
	Hosts functions related to Timeline Entry items
	"""
	
	@doc """
	takes `{timeline_id, timestamp, body, sources, imgurl, uid}` returns generated id

	returns `{:ok, id}` or `{:error, %{code: code, message: string}}`
	""" 
	def create({ timeline_id, timestamp, title, body, sources, imgurl, uid }) do

		{:ok, dt} = DateTime.from_unix(timestamp)

		case Postgrex.query(
			Discourse.DB, 
			"INSERT INTO TimelineEntries (timeline, timestamp, title, body, sources, imgurl, author) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id",
			[timeline_id, dt, title, body, sources, imgurl, uid]) do
				{:ok, resp} -> 
					[[id]] = resp.rows
					{:ok, id}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail }}
		end
	end

	# updates timeline entry, returns postgres response
	def update({id, timeline_id, timestamp, title, body, sources, imgurl, uid}) do

		{:ok, dt} = DateTime.from_unix(timestamp)

		case Postgrex.query(
			Discourse.DB, 
			"UPDATE TimelineEntries SET (timeline, timestamp, body, sources, imgurl) VALUES ($1, $2, $3, $4, $5) WHERE id=$6 AND author=$7",
			[timeline_id, dt, title, body, sources, imgurl, id, uid]) do
				{:ok, resp} -> {:ok, resp}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	# finds all entries for a timeline id, returns rows as [id, timeline, timestamp, body, sources, imgurl, upvotes, downvotes].
	def from_timeline_id(id) do

		case Postgrex.query(Discourse.DB, "SELECT id, timeline, extract(epoch from timestamp), title, body, sources, imgurl, upvotes, downvotes FROM TimelineEntries WHERE timeline=$1", [id]) do
			{:ok, resp} -> {:ok, resp.rows 
				|> Enum.map(fn([entry_id, timeline, timestamp, title, body, sources, imgurl, upvotes, downvotes]) -> %{
					id: entry_id,
					timeline: timeline,
					timestamp: timestamp,
					title: title,
					body: body,
					sources: sources,
					imgurl: imgurl,
					upvotes: upvotes,
					downvotes: downvotes } end)}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end
end