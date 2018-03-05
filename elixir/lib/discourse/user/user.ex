defmodule Discourse.User do
	
	def create({username, email}) do
		# postgres sql insert
		IO.puts "inserting...."
		case Postgrex.query(Discourse.DB, "INSERT INTO users (email, username) VALUES ($1, $2) RETURNING id", [email, username]) do
			{:ok, resp} -> 
				[[uid]] = resp.rows 
				{:ok, uid}
			{:error, err} -> 
				case err.postgres do
					%{code: :unique_violation} -> {:error, "email already exists"}
					other -> 
						IO.inspect other
						{:error, "something went wrong. #{err.postgres.detail}"}
				end
		end
	end

	def from_token({username, token}) do
		IO.puts "finding..."
		validator = token_hash(token)
		case Postgrex.query(Discourse.DB, "SELECT * FROM auth_tokens WHERE token=$1 AND username=$2", [validator, username]) do
			{:ok, resp} -> 
				IO.inspect resp.rows
				[r|_] = resp.rows
				{:ok, r }
			{:error, err} -> 
				{:error, "#{err.postgres.detail}"}
			
		end
	end

	def save_token({uid, username, token}) do 
		IO.puts "inserting token..."
		validator = token_hash(token)
		case Postgrex.query(Discourse.DB, "INSERT INTO auth_tokens (uid, username, token, expires) VALUES ($1, $2, $3, now() + interval '90 days')", [uid, username, validator]) do
			{:ok, resp} -> {:ok, ""}
			{:error, err} -> {:error, "#{err.postgres.detail}"}
		end
	end

	defp token_hash(token) do
		:crypto.hash(:md5, token) 
		|> Base.url_encode64 
		|> binary_part(0, 12)
	end

end