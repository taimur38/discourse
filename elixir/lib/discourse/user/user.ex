defmodule Discourse.User do
	@moduledoc """
	Provides functions related to User creation, retrieval, and token management
	"""
	
	# creates a user, returns {:ok, uid}
	def create({username, email}) do
		# postgres sql insert
		IO.puts "inserting...."
		case Postgrex.query(Discourse.DB, "INSERT INTO users (email, username) VALUES ($1, $2) RETURNING id", [email, username]) do
			{:ok, resp} -> 
				[[uid]] = resp.rows 
				{:ok, uid}
			{:error, err} -> {:error, %{ code: err.postgres.code, message: err.postgres.detail }}
		end
	end

	# outputs {:ok, [uid, username, expiration date as unix timestamp] of user with matching token}
	def from_token({username, token}) do
		IO.puts "finding..."
		validator = token_hash(token)
		case Postgrex.query(Discourse.DB, "SELECT uid, username, extract(epoch from expires) FROM auth_tokens WHERE token=$1 AND username=$2", [validator, username]) do
			{:ok, resp} -> 
				IO.inspect resp.rows
				[r|_] = resp.rows
				{:ok, r}
			{:error, err} -> {:error, %{ code: err.postgres.code, message: err.postgres.detail }}
		end
	end

	# saves token, outputs standard error format
	def save_token({uid, username, token}) do 
		IO.puts "inserting token..."
		validator = token_hash(token)
		case Postgrex.query(
			Discourse.DB, 
			"INSERT INTO auth_tokens (uid, username, token, expires) VALUES ($1, $2, $3, now() + interval '90 days')",
			[uid, username, validator]) do
				{:ok, resp} -> {:ok, ""}
				{:error, err} -> {:error, %{ code: err.postgres.code, message: err.postgres.detail }}
		end
	end

	# updates token, doesn't handle error
	def update_token(old_token, new_token) do
		Postgrex.query(
			Discourse.DB, 
			"UPDATE auth_tokens SET token=$1, expires = now() + interval '90 days' WHERE token=$2", 
			[token_hash(new_token), token_hash(old_token)])
	end

	#deletes token doesnt handle error
	def delete_token(token) do
		Postgrex.query(Discourse.DB, "DELETE FROM auth_tokens WHERE token=$1", token_hash(token))
	end

	# hashes token so it can be matched to backend value
	defp token_hash(token) do
		:crypto.hash(:md5, token) 
		|> Base.url_encode64 
		|> binary_part(0, 12)
	end

end