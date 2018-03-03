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

	def check({username, email}) do
		Postgrex.query!(Discourse.DB, "SELECT * FROM ")
	end
end