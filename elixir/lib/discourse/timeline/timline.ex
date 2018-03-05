defmodule Discourse.Timeline do
	@moduledoc """
	contains functions for high level timeline object
	"""
	
	# inserts timeline into db. accepts {title, uid} returns generated ID
	def create({ title, uid }) do

		case Postgrex.query(Discourse.DB, "INSERT INTO timelines (title, author) VALUES ($1, $2) RETURNING id", [title, uid]) do
			{:ok, resp} -> 
				[[timeline_id]] = resp.rows
				{:ok, timeline_id}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end

	# finds all timelines for a user id
	def from_userid(uid) do

		case Postgrex.query(Discourse.DB, "SELECT id, title, author FROM timelines WHERE author=$1", [uid]) do
			{:ok, resp} -> {:ok, resp.rows}
			{:error, err} -> {:error, %{code: err.postgres.code, message: err.postgres.detail}}
		end

	end

	# finds all timelines for a username
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