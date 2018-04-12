defmodule Discourse.Timeline do
	@moduledoc """
	contains functions for high level timeline object
	"""
	
	@doc """
	inserts timeline into db. accepts {title, uid} returns generated ID
	"""
	def create({ title, uid }) do

		case Postgrex.query(Discourse.DB, "INSERT INTO timelines (title, author) VALUES ($1, $2) RETURNING id", [title, uid]) do
			{:ok, resp} -> 
				[[timeline_id]] = resp.rows
				{:ok, timeline_id}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end

	@doc """
	edits timeline
	"""
	def edit({ id, title, published }) do
		case Postgrex.query(Discourse.DB, "UPDATE timelines SET title=$1, published=$2 WHERE id=$3", [title, published, id]) do
			{:ok, resp} -> {:ok}
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

	@doc """
	gets all relevant timeline info
	"""
	def from_id(id) do
		case Postgrex.query(Discourse.DB, "SELECT title, author, username, published from timelines join users on timelines.author=users.id where timelines.id=$1", [id]) do
			{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{message: "Timeline not found"}}
			{:ok, resp} -> 
				[[title, author, username, published]] = resp.rows
				case Discourse.Timeline.Entry.from_timeline_id(id) do
					{:ok, rows} -> {:ok, %{
						id: id,
						title: title,
						published: published,
						userid: author,
						username: username,
						entries: rows }}
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
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail }}
		end
	end

	@doc """
	finds all timelines for a username
	"""
	def from_username(username) do
		
		case Postgrex.query(
			Discourse.DB,
			"SELECT users.id, timelines.id, timelines.title, extract(epoch from timelines.created_at), timelines.published
			FROM users JOIN timelines on users.id = timelines.author 
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