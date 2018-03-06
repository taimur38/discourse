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
		case Postgrex.query(Discourse.DB, "SELECT title, author, username from timelines join users on timelines.author=users.id where timelines.id=$1", [id]) do
			{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{message: "Timeline not found"}}
			{:ok, resp} -> 
				[[title, author, username]] = resp.rows
				case Discourse.Timeline.Entry.from_timeline_id(id) do
					{:ok, rows} -> {:ok, %{
						title: title,
						userid: author,
						username: username,
						entries: rows }}
					{:error, err} -> {:error, err}
				end
			
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}

		end
	end


	@doc """
	finds all timelines for a username
	"""
	def from_username(username) do
		
		case Postgrex.query(
			Discourse.DB,
			"SELECT users.id, timelines.id, timelines.title, timelines.author 
			FROM users JOIN tmielines on users.id = timelines.author 
			WHERE users.username=$1", [username]) do
				{:ok, resp} -> {:ok, resp.rows}
				{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
			end
	end

end