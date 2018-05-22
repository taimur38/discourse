defmodule Discourse.Notification do
	@moduledoc """
	contains functions for working with notifications
	"""

	def comment_reply({user_id, comment_id, parent_entry, title, json}) do
		
		case Postgrex.query(
			Discourse.DB,
			"
			INSERT INTO Notifications (uid, type, target_id, parent_id, title, timestamp, meta)
			VALUES ($1, $2, $3, $4, $5, now(), $6)
			RETURNING id, extract(epoch from timestamp)
			",
			[user_id, 0, comment_id, parent_entry, title, json]
		) do
			{:ok, resp} ->
				[[id, timestamp]] = resp.rows
				{:ok, id}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	def entry_reply({user_id, parent_entry, title, timeline, json}) do
		
		case Postgrex.query(
			Discourse.DB,
			"
			INSERT INTO Notifications (uid, type, target_id, parent_id, title, timestamp, meta)
			VALUES ($1, $2, $3, $4, $5, now(), $6)
			RETURNING id, extract(epoch from timestamp)
			",
			[user_id, 1, parent_entry, timeline, title, json]
		) do
			{:ok, resp} -> 
				[[id, timestamp]] = resp.rows
				{:ok, id}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	def for_user({user_id}) do

		case Postgrex.query(
			Discourse.DB,
			"SELECT id, type, target_id, extract(epoch from timestamp), title, read, parent_id, meta FROM Notifications WHERE uid=$1",
			[user_id]
		) do
			{:ok, resp} -> {:ok, resp.rows
				|> Enum.map(fn([id, type, target_id, timestamp, title, read, parent_id, meta]) -> %{
					id: id,
					type: get_type(type),
					target_id: target_id,
					timestamp: timestamp,
					title: title,
					read: read,
					parent_id: parent_id,
					meta: meta
				} end)}

			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	def mark_read(notif_id) do
		case Postgrex.query(
			Discourse.DB,
			"UPDATE Notifications set read=true WHERE id=$1",
			[notif_id]
		) do
			{:ok, resp} -> {:ok, %{}}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	defp get_type(type_num) do
		case type_num do
			0 -> "CommentReply"
			1 -> "EntryReply"
			_ -> "OtherShit"
		end
	end

end