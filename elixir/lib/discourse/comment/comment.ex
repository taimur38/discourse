defmodule Discourse.Comment do
	@moduledoc """
	Contains functions for working with comments
	"""

	def create({ uid, username, body, parent_entry, nil, timeline}) do
		{:ok, %Postgrex.Result{num_rows: 1, rows: [[target_id]]}} = Postgrex.query(Discourse.DB, "SELECT author FROM timelineentries WHERE id=$1", [parent_entry])

		result = write({uid, username, body, parent_entry, timeline, "/"})

		#if uid != target_id, do: Discourse.Notification.entry_reply({ target_id, parent_entry, "#{username} replied to your timeline entry"})
		with {:ok, json} <- result do
			Discourse.Notification.entry_reply({ target_id, parent_entry, "#{username} replied to your timeline entry", timeline, json})
		end

		result
	end
	
	# set time in db maybe
	def create({ user_id, username, body, parent_entry, parent_comment, timeline}) do

		{:ok, %Postgrex.Result{num_rows: 1, rows: [[path, target_id]]}} = Postgrex.query(Discourse.DB, "SELECT path, uid FROM Comments WHERE id=$1", [parent_comment])

		result = write({user_id, username, body, parent_entry, timeline, "#{path}/#{parent_comment}"})

		with {:ok, json} <- result do
			Discourse.Notification.comment_reply({target_id, parent_entry, timeline, "#{username} replied to your comment", json})
		end

		# if user_id != target_id, do: Discourse.Notification.comment_reply({target_id, parent_comment, parent_entry, "#{username} replied to your comment"})

		result
	end

	defp write({user_id, username, body, parent_entry, timeline, path} = args) do 
		case Postgrex.query(
			Discourse.DB,
			"
			INSERT INTO Comments (uid, username, body, timestamp, parent_entry, parent_timeline, path ) 
			VALUES ($1, $2, $3, now(), $4, $5, $6)
			
			RETURNING id, extract(epoch from timestamp)",
			[user_id, username, body, parent_entry, timeline, path]) do

				{:ok, resp} -> 
					[[id, timestamp]] = resp.rows
					{:ok, %{
						id: id,
						user: %{
							id: user_id,
							username: username,
						},
						replies: %{},
						body: body,
						timestamp: timestamp,
						parent_entry: parent_entry,
						parent_timeline: timeline,
						path: path
					}}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

end