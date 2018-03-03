defmodule Discourse.ServerB do
	
	use Ace.HTTP.Service, [port: 8080, cleartext: true]

	@impl Raxx.Server
	def handle_request(%{method: :GET, path: []}, _state) do
		response(:ok)
		|> set_header("content-type", "text/plain")
		|> set_body("hello")
	end

	def handle_request(%{method: :GET, path: ["api", "user", uid, "create"]}, _) do
		IO.puts "userid"
		IO.inspect uid

		response(:ok)
		|> set_header("content-type", "text/plain")
		|> set_body("hi")
	end

	def handle_request(%{method: :GET, path: ["api", "user", username, "signup", token]}, _) do

		IO.puts "handling login"
		IO.inspect :ets.lookup(:token_cache, {token, username})
		case :ets.lookup(:token_cache, {token, username}) do
			[{{^token, ^username}, email}] -> 
				IO.puts "lookup succeed"
				:ets.delete(:token_cache, {token, username})
				case Discourse.User.create({ username, email }) do
					{:ok, uid} -> 
						response(:ok)
						|> set_header("content-type", "application/json")
						|> set_body(Poison.encode!(%{success: true, uid: uid}, keys: :atoms!))
					{:error, message} -> 
						response(:ok)
						|> set_header("content-type", "application/json")
						|> set_body(Poison.encode!(%{success: false, message: message}, keys: :atoms!))
				end

			other -> 
				response(:ok)
				|> set_header("content-type", "text/plain")
				|> set_body("lookup failed!!")
		end
	end

	def handle_request(req = %{method: :POST, path: ["api", "user", "create"], body: body}, _) do
		payload = Poison.decode!(body, [keys: :atoms])

		resp = case payload do
			%{ email: email, username: username } -> 
				token = :rand.uniform(899999999) + 100000000

				IO.inspect token
				IO.inspect :ets.insert(:token_cache, {{"#{token}", username}, email}) # delete this after 10 minutes
				Discourse.Email.send({"hello", "<div>Your magic login link is <a href=\"http://localhost:8080/api/user/#{username}/signup/#{token}\">here</a>.</div>"}, {username, email})
				%{ succeed: true }

				response(:ok)
				|> set_header("content-type", "text/plain")
				|> set_body("Go here to log in http://localhost:8080/api/user/#{username}/login/#{token}")

			_ -> response(:ok) |> set_body("fail")
		end


		# response(:ok)
		# |> set_header("content-type", "application/json")
		# |> set_body(Poison.encode!(resp))
	end

	def handle_request(%{}, _state) do
		response(404)
	end
end