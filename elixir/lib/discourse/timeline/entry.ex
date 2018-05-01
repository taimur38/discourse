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
			"SELECT a.id, a.title, a.body, a.sources, a.author, a.imgurl, a.timestamp, a.timeline, a.upvotes, a.downvotes, 
			b.uid, b.username, b.body, extract(epoch from b.timestamp), b.path, b.id
			FROM TimelineEntries a LEFT OUTER JOIN Comments b ON a.id=b.parent_entry
			WHERE a.id=$1 AND a.timeline=$2",
			[entry_id, timeline_id]) do
				{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{code: :invalid_entry, message: "entry not found"}}
				{:ok, resp} -> 
					[[id, title, body, sources, userid, imgurl, timestamp, timeline, upvotes, downvotes | _] | _] = resp.rows

					comment_tree =resp.rows
						|> Enum.filter(fn(row) -> List.last(row) != nil end)
						|> Enum.map(fn(row) -> 
							[comment_uid, comment_username, comment_body, comment_ts, comment_path, comment_id] = Enum.slice(row, -6..-1)
							%{
								id: comment_id,
								user: %{
									id: comment_uid,
									username: comment_username
								},
								body: comment_body,
								timestamp: comment_ts,
								replies: %{},
								path: comment_path
							} end)
						|> Enum.sort(fn( %{path: a}, %{path: b} ) -> a < b end)
						|> Enum.reduce(%{}, fn(comment, comment_tree) -> 
							path = get_path(comment)
							comment_tree = Kernel.put_in(comment_tree, path, comment) 
						end)

					{:ok, %{
						id: id,
						timeline: timeline,
						timestamp: timestamp,
						title: title,
						body: body,
						sources: sources,
						imgurl: imgurl,
						userid: userid,
						comments: comment_tree
					}}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	defp get_path(%{id: id, path: nil}) do 
		["#{id}"]
	end

	defp get_path(%{path: path, id: id}) do
		p = String.split(path, "/")
			|> Enum.filter(&(&1 != ""))
			|> Enum.reduce([], fn(parent_id, acc) -> acc ++ [parent_id, :replies] end)
		p ++ ["#{id}"]
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

		case Postgrex.query(Discourse.DB, "
		SELECT 
			a.id,
			a.timeline,
			extract(epoch from a.timestamp),
			a.title,
			a.body,
			a.sources,
			a.imgurl,
			a.upvotes,
			a.downvotes,
			a.author, 
			count(b.id) as num_comments
		FROM TimelineEntries a LEFT OUTER JOIN comments b ON a.id=b.parent_entry
		WHERE timeline=$1
		GROUP BY a.id", [id]) do
			{:ok, resp} -> {:ok, resp.rows 
				|> Enum.map(fn([entry_id, timeline, timestamp, title, body, sources, imgurl, upvotes, downvotes, author, num_comments]) -> %{
					id: entry_id,
					timeline: timeline,
					timestamp: timestamp,
					title: title,
					body: body,
					sources: sources,
					imgurl: imgurl,
					upvotes: upvotes,
					downvotes: downvotes,
					num_comments: num_comments,
					userid: author } end)}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end
end