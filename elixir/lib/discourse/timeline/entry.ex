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
					{:ok, %{
						id: id,
						timeline: timeline_id,
						timestamp: timestamp,
						title: title,
						body: body,
						sources: sources,
						imgurl: imgurl,
						userid: uid
					}}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	def get({ timeline_id, entry_id }) do 

		case Postgrex.query(
			Discourse.DB,
			"SELECT id, title, body, sources, author, imgurl, timestamp, timeline, upvotes, downvotes from TimelineEntries where id=$1 and timeline=$2",
			[entry_id, timeline_id]) do
				{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{code: :invalid_entry, message: "entry not found"}}
				{:ok, resp} -> 
					[[id, title, body, sources, userid, imgurl, timestamp, timeline, upvotes, downvotes]] = resp.rows
					{:ok, %{
						id: id,
						timeline: timeline,
						timestamp: timestamp,
						title: title,
						body: body,
						sources: sources,
						imgurl: imgurl,
						userid: userid
					}}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	# updates timeline entry, returns postgres response
	def update({id, timeline_id, timestamp, title, body, sources, imgurl, uid}) do

		{:ok, dt} = DateTime.from_unix(timestamp)

		case Postgrex.query(
			Discourse.DB, 
			"UPDATE TimelineEntries SET timeline=$1, timestamp=$2, title=$3, body=$4, sources=$5, imgurl=$6 WHERE id=$7 AND author=$8",
			[timeline_id, dt, title, body, sources, imgurl, id, uid]) do
				{:ok, resp} -> {:ok, %{
					id: id,
					timeline: timeline_id,
					timestamp: timestamp,
					title: title,
					body: body,
					sources: sources,
					imgurl: imgurl,
					userid: uid
				}}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	# deletes timeline entry
	def delete({id, uid}) do 
		case Postgrex.query(
			Discourse.DB,
			"DELETE FROM TimelineEntries WHERE id=$1 AND author=$2",
			[id, uid]
		) do
			{:ok, resp} -> if resp.num_rows == 1, do: {:ok}, else: {:error, %{message: "Entry Not Found"}}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail }}
		end
	end

	# finds all entries for a timeline id, returns rows as [id, timeline, timestamp, body, sources, imgurl, upvotes, downvotes].
	def from_timeline_id(id) do

		case Postgrex.query(Discourse.DB, "SELECT id, timeline, extract(epoch from timestamp), title, body, sources, imgurl, upvotes, downvotes, author FROM TimelineEntries WHERE timeline=$1", [id]) do
			{:ok, resp} -> {:ok, resp.rows 
				|> Enum.map(fn([entry_id, timeline, timestamp, title, body, sources, imgurl, upvotes, downvotes, author]) -> %{
					id: entry_id,
					timeline: timeline,
					timestamp: timestamp,
					title: title,
					body: body,
					sources: sources,
					imgurl: imgurl,
					upvotes: upvotes,
					downvotes: downvotes,
					userid: author } end)}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end
end