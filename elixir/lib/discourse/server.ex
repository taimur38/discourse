defmodule Discourse.Server do
	
	use Ace.HTTP.Service, [port: 8080, cleartext: true]

	@impl Raxx.Server
	def handle_request(%{method: :GET, path: []}, _state) do
		response(:ok)
		|> set_header("content-type", "text/plain")
		|> set_body("hello")
	end

	# endpoint for api login
	def handle_request(%{method: :GET, path: ["api", "user", username, "login", token]}, _) do

		IO.puts "handling login"

		IO.inspect Discourse.User.from_token({username, token})

		case Discourse.User.from_token({username, token}) do
			{:ok, _} -> success(%{})
			{:error, err }-> failed(err)
			crap -> 
				IO.inspect crap
				failed("nothin")
		end
	end

	# endpoint for user creation
	def handle_request(%{method: :POST, path: ["api", "user", "create"], body: body}, _) do
		payload = Poison.decode!(body, [keys: :atoms])

		case payload do
			%{ email: email, username: username } -> 
				token = :crypto.strong_rand_bytes(12) |> Base.url_encode64 |> binary_part(0, 12)

				case Discourse.User.create({ username, email }) do
					{:ok, uid} -> 
						{:ok, _} = Discourse.User.save_token({uid, username, token})

						Discourse.Email.send({
							"Hello - sign in to Discourse",
							"<div>
								Your magic login link is <a href=\"http://localhost:8080/api/user/#{username}/login/#{token}\">here</a>.
							</div>"
						}, email)

						success(%{id: uid})

					{:error, err} -> failed(err)
				end

			_ -> response(:ok) |> set_body(Poison.encode!(%{success: false, message: "body requires email and username"}, keys: :atoms!))
		end
	end

	def handle_request(%{method: :GET, path: ["api", "timeline", id]}, _) do
		{parsed_id, _} = Integer.parse(id)
		case Discourse.Timeline.from_id(parsed_id) do
			{:ok, timeline} -> success(timeline)
			{:error, err} -> failed(err)
		end

	end

	# endpoint for getting timeline entries
	def handle_request(%{method: :GET, path: ["api", "timeline", id, "entries"]}, _) do
		
		{parsed_id, _} = Integer.parse(id)
		case Discourse.Timeline.Entry.from_timeline_id(parsed_id) do
			{:ok, entries} -> 
				IO.puts "got entries"
				success(entries)

			{:error, err} ->failed(err)
		end
	end

	# endpoint for creating a timeline
	def handle_request(%{method: :POST, path: ["api", "timeline", "create"], body: body}, _) do
		payload = Poison.decode!(body, [keys: :atoms])

		case payload do
			%{title: title, username: username, token: token} -> 
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Timeline.create({title, uid}) do
					{:ok, id} -> success(%{id: id, title: title, author: uid})
					{:error, err} -> failed(err)
				end
			_ -> failed("missing required fields")
		end
	end

	#endpoint for creating a timeline entry
	def handle_request(%{method: :POST, path: ["api", "timeline", "entry", "create"], body: post_body}, _) do
		payload = Poison.decode!(post_body, [keys: :atoms])

		case payload do
			%{body: body, sources: sources, imgurl: imgurl, timeline: timeline, timestamp: ts, token: token, username: username} ->
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Timeline.Entry.create({timeline, ts, body, sources, imgurl, uid}) do
					{:ok, id} -> success(%{
							id: id,
							timeline: timeline,
							timestamp: ts,
							body: body,
							sources: sources,
							imgurl: imgurl,
							author: uid})
					{:error, err} -> failed(err)
				end
			other ->
				IO.inspect other
				failed("missing fields")

		end
	end

	def handle_request(%{} = req, _state) do
		IO.inspect req
		response(404)
	end

	defp success(payload) do
		response(:ok)
		|> set_header("content-type", "application/json")
		|> set_body(Poison.encode!(%{
				success: true,
				message: "",
				payload: payload 
			}, keys: :atoms!))
	end

	defp failed(%{message: message}) do
		response(:ok)
		|> set_header("content-type", "application/json")
		|> set_body(Poison.encode!(%{
				success: false,
				message: message,
				payload: %{}
			}, keys: :atoms!))
	end

	defp failed(message) do
		response(:ok)
		|> set_header("content-type", "application/json")
		|> set_body(Poison.encode!(%{
				success: false,
				message: message,
				payload: %{}
			}, keys: :atoms!))
	end
end