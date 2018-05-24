defmodule Discourse.Timeline do
	@moduledoc """
	contains functions for high level timeline object
	"""
	
	@doc """
	inserts timeline into db. accepts {title, uid} returns generated ID
	"""
	def create({ title, uid }) do

		case Postgrex.query(Discourse.DB, "INSERT INTO timelines (title, author, editors) VALUES ($1, $2, $3) RETURNING id", [title, uid, [uid]]) do
			{:ok, resp} -> 
				[[timeline_id]] = resp.rows
				{:ok, timeline_id}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end

	@doc """
	edits timeline
	"""
	def edit({ id, title, published, uid }) do
		case Postgrex.query(Discourse.DB, "UPDATE timelines SET title=$1 WHERE id=$3 AND editors @> $4 RETURNING id", [title, id, [uid]]) do
			{:ok, %Postgrex.Result{num_rows: 1}} -> {:ok}
			{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{message: "You don't have permission to edit this timeline"}}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	@doc """
	Add a member to the editors list
	"""
	def add_editor({ id, uid, new_editor }) do
		case Postgrex.query(Discourse.DB, "UPDATE timelines SET editors=array_append(editors, $1) WHERE id=$2 AND editors @> $3 AND NOT editors @> $4RETURNING editors", [new_editor, id, [uid], [new_editor]]) do
			{:ok, %Postgrex.Result{num_rows: 1, rows: [[editors]]}} -> {:ok, %{ editors: editors}}
			{:ok, other} -> {:error, %{message: "You don't have permission to edit this timeline"}}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	@doc """
	Remove member from editors list. The author cannot be removed
	"""
	def remove_editor({ id, uid, remove_editor }) do
		case Postgrex.query(Discourse.DB, "UPDATE timelines SET editors=array_remove(editors, $1) WHERE id=$2 AND editors @> $3 AND NOT author=$4  RETURNING editors", [remove_editor, id, [uid], [remove_editor], uid]) do
			{:ok, %Postgrex.Result{num_rows: 1, rows: [[editors]]}} -> {:ok, %{ editors: editors}}
			{:ok, other} -> {:error, %{message: "You Don't have permission to edit this timeline"}}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	@doc """
	finds all timelines for a user id
	"""
	def from_userid(uid) do

		case Postgrex.query(Discourse.DB, "SELECT id, title, author FROM timelines WHERE author=$1", [uid]) do
			{:ok, resp} -> {:ok, resp.rows}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	def is_editor({uid, timeline_id}) do

		case Postgrex.query(Discourse.DB, "select editors @> $1 from timelines where id=$2", [[uid], timeline_id]) do
			{:ok, resp} -> 
				[[val]] = resp.rows
				{:ok, val}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	@doc """
	gets all relevant timeline info
	"""
	def from_id(id) do
		case Postgrex.query(
			Discourse.DB,
			"SELECT title, author, users.id, username, published
			FROM (SELECT *, unnest(editors) FROM timelines WHERE id=$1) timelines JOIN users ON timelines.unnest=users.id
			", [id]) do
			{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{message: "Timeline not found"}}
			{:ok, resp} -> 
				the_timeline = resp.rows
				|> Enum.reduce(%{}, fn([title, author_id, user_id, username, published], timeline_struct) -> 

					case timeline_struct do
						%{id: id, title: title, published: published, author: author_map, editors: editors_list} -> 
							%{ timeline_struct | editors: [%{id: user_id, username: username} | editors_list]}
						other -> 
							timeline_struct = %{id: id, title: title, published: published }
							if author_id == user_id do
								timeline_struct
								|> Map.put(:author, %{id: user_id, username: username})
								|> Map.put(:editors, [%{id: user_id, username: username} | Map.get(other, :editors, [])])
							else
								%{timeline_struct | editors: [%{id: user_id, username: username} | Map.get(other, :editors, [])]}
							end
					end
				end)

				case Discourse.Timeline.Entry.from_timeline_id(id) do
					{:ok, rows} -> {:ok, Map.put(the_timeline, :entries, rows)}
					{:error, err} -> {:error, err}
				end
			
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}

		end
	end

	@doc """
	gets all recent timelines
	"""
	def recent(limit) do
		case Postgrex.query(
			Discourse.DB,
			"SELECT a.id, a.title, extract(epoch from a.created_at), a.author, b.username
			FROM timelines a JOIN users b ON a.author=b.id
			WHERE a.published=TRUE
			ORDER BY a.created_at DESC
			LIMIT $1", [limit]) do

				{:ok, resp} -> {:ok, resp.rows 
					|> Enum.map(fn([id, title, created_at, uid, username]) -> %{
							id: id,
							title: title,
							created_at: created_at,
							author: %{
								id: uid,
								username: username
							}
						} end)}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end
	end

	@doc """
	finds all timelines for a username
	"""
	def from_username(username) do
		
		case Postgrex.query(
			Discourse.DB,
			"SELECT users.id, timelines.id, timelines.title, extract(epoch from timelines.created_at), timelines.published
			FROM users JOIN (select *, unnest(editors) from timelines) timelines on users.id = timelines.unnest
			WHERE users.username=$1", [username]) do
				{:ok, resp} -> {:ok, resp.rows
					|> Enum.map(fn([uid, timeline, title, created, published]) -> %{
							author: %{
								id: uid,
								username: username
							},
							id: timeline,
							title: title,
							created_at: created,
							published: published
						} end)}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
			end
	end

end