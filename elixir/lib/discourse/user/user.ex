defmodule Discourse.User do
	@moduledoc """
	Provides functions related to User creation, retrieval, and token management
	"""

	@doc """
	creates a user, returns {:ok, uid}
	"""
	def create({username, email}) do
		# postgres sql insert
		IO.puts "inserting...."
		case Postgrex.query(Discourse.DB, "INSERT INTO users (email, username) VALUES ($1, $2) RETURNING id", [email, username]) do
			{:ok, resp} -> 
				[[uid]] = resp.rows 
				{:ok, uid}
			{:error, err} -> pgerror(err)
		end
	end

	@doc """
	returns user from email
	"""
	def from_email(email) do
		case Postgrex.query(Discourse.DB, "SELECT id, email, username FROM users WHERE email=$1", [email]) do
			{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{code: :invalid_email, message: "invalid email"}}
			{:ok, resp} -> 
				[[uid, email, username]] = resp.rows
				{uid, email, username}
			{:error, err} -> pgerror(err)
		end
	end

	@doc """
	outputs {:ok, [uid, username, expiration date as unix timestamp] of user with matching token}
	"""
	def from_token({username, token}) do
		validator = token_hash(token)
		case Postgrex.query(Discourse.DB, "SELECT uid, username, extract(epoch from expires) FROM auth_tokens WHERE token=$1 AND username=$2", [validator, username]) do
			{:ok, %Postgrex.Result{num_rows: 0}} -> {:error, %{code: :invalid, message: "invalid auth token"}}
			{:ok, resp} -> 
				[r|_] = resp.rows
				{:ok, r}
			{:error, err} -> pgerror(err)
		end
	end

	@doc """
	searches user for autocomplete
	"""
	def lookup(username_prefix) do

		case Postgrex.query(
			Discourse.DB, 
			"SELECT id, username FROM users WHERE username LIKE $1 || '%'",
			[username_prefix]) do
				{:ok, resp} -> {:ok, resp.rows
						|> Enum.map(fn([id, username]) -> %{
							id: id, username: username
						} end )}
				{:error, err} -> 
					IO.inspect err
					# {:error, %{code: err.postgres.code, message: err.postgres.detail}}
					{:error, %{code: err.postgres.code, message: "err"}}
			end
	end

	@doc """
	saves token, outputs standard error format
	"""
	def save_token({uid, username, token}) do 
		IO.puts "inserting token..."
		validator = token_hash(token)
		case Postgrex.query(
			Discourse.DB, 
			"INSERT INTO auth_tokens (uid, username, token, expires) VALUES ($1, $2, $3, now() + interval '90 days')",
			[uid, username, validator]) do
				{:ok, _} -> {:ok}
				{:error, err} -> pgerror(err)
		end
	end

	defp pgerror(err) do
		IO.inspect err
		{:error, %{ code: err.postgres.code, message: err.postgres.detail }}
	end

	@doc """
	updates token, doesn't handle error
	"""
	def update_token(old_token, new_token) do
		Postgrex.query(
			Discourse.DB, 
			"UPDATE auth_tokens SET token=$1, expires = now() + interval '90 days' WHERE token=$2", 
			[token_hash(new_token), token_hash(old_token)])
	end

	@doc """
	deletes token doesnt handle error
	"""
	def delete_token(token) do
		Postgrex.query(Discourse.DB, "DELETE FROM auth_tokens WHERE token=$1", token_hash(token))
	end

	defp token_hash(token) do
		:crypto.hash(:md5, token) 
		|> Base.url_encode64 
		|> binary_part(0, 12)
	end

end