defmodule Discourse.Server do
	
	use Ace.HTTP.Service, [port: 8080, cleartext: true]

	@impl Raxx.Server
	def handle_request(%{method: :GET, path: []}, _state) do
		response(:ok)
		|> set_header("content-type", "text/plain")
		|> set_body("hello")
	end

	def handle_request(%{method: :GET, path: ["api", "user", username, "login", token]}, _) do

		IO.puts "handling login"

		IO.inspect Discourse.User.from_token({username, token})

		case Discourse.User.from_token({username, token}) do

			{:ok, _} -> 
				response(:ok) 
				|> set_header("content-type", "application/json")
				|> set_body(Poison.encode!(%{ success: true }, keys: :atoms!))

			{:error, message }-> 
				response(:ok)
				|> set_header("content-type", "application/json")
				|> set_body(Poison.encode!(%{success: false, message: message}, keys: :atoms!))
		end
	end

	def handle_request(req = %{method: :POST, path: ["api", "user", "create"], body: body}, _) do
		payload = Poison.decode!(body, [keys: :atoms])

		resp = case payload do
			%{ email: email, username: username } -> 
				token = :crypto.strong_rand_bytes(12) |> Base.url_encode64 |> binary_part(0, 12)

				case Discourse.User.create({ username, email }) do
					{:ok, uid} -> 
						{:ok, _} = Discourse.User.save_token({uid, username, token})

						Discourse.Email.send({"Hello - sign in to Discourse", "<div>Your magic login link is <a href=\"http://localhost:8080/api/user/#{username}/login/#{token}\">here</a>.</div>"}, email)

						response(:ok)
						|> set_header("content-type", "application/json")
						|> set_body(Poison.encode!(%{success: true, uid: uid}, keys: :atoms!))

					{:error, message} -> 
						response(:ok)
						|> set_header("content-type", "application/json")
						|> set_body(Poison.encode!(%{success: false, message: message}, keys: :atoms!))
				end

			_ -> response(:ok) |> set_body(Poison.encode!(%{success: false, message: "body requires email and username"}, keys: :atoms!))
		end

	end

	def handle_request(%{}, _state) do
		response(404)
	end
end