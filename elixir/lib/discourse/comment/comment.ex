defmodule Discourse.Comment do
	@moduledoc """
	Contains functions for working with comments
	"""

	def create({ uid, username, body, parent_entry, nil}) do
		write({uid, username, body, parent_entry, "/"})
	end
	
	# set time in db maybe
	def create({ user_id, username, body, parent_entry, parent_comment }) do

		{:ok, %Postgrex.Result{num_rows: 1, rows: [[path]]}} = Postgrex.query(Discourse.DB, "SELECT path FROM Comments WHERE id=$1", [parent_comment])

		write({user_id, username, body, parent_entry, "#{path}/#{parent_comment}"})
	end

	defp write({user_id, username, body, parent_entry, path} = args) do 
		IO.inspect args
		case Postgrex.query(
			Discourse.DB,
			"
			INSERT INTO Comments (uid, username, body, timestamp, parent_entry, path ) 
			VALUES ($1, $2, $3, now(), $4, $5)
			
			RETURNING id, extract(epoch from timestamp)",
			[user_id, username, body, parent_entry, path]) do

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
						path: path
					}}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

end