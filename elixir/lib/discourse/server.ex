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

		case Discourse.User.from_token({username, token}) do
			{:ok, [uid, username, _]} -> success(%{
				id: uid,
				username: username
			})
			{:error, err }-> failed(err)
			crap -> 
				IO.inspect crap
				failed("nothin")
		end
	end

	# token generation endpoint
	def handle_request(%{method: :POST, path: ["api", "user", "login"], body: body}, _) do

		case Poison.decode!(body, [keys: :atoms]) do
			%{email: email} -> 
				case Discourse.User.from_email(email) do
					{uid, _, username} -> 
						token = :crypto.strong_rand_bytes(12) |> Base.url_encode64 |> binary_part(0, 12)
						Discourse.Email.send({
							"Log In To Discourse",
							"<div>
								Welcome back, #{username}. Your login link is <a href=\"http://localhost:3000/verify?username=#{username}&token=#{token}\">here</a>.
							</div>"
						}, email)
						Discourse.User.save_token({uid, username, token})
						success(%{})
					{:error, err} -> failed(err)
				end
			_ -> failed("missing email field")
		end
	end

	# endpoint for user creation
	def handle_request(%{method: :POST, path: ["api", "user", "create"], body: body}, _) do
		payload = Poison.decode!(body, [keys: :atoms])
		IO.inspect payload

		case payload do
			%{ email: email, username: username } -> 
				token = :crypto.strong_rand_bytes(12) |> Base.url_encode64 |> binary_part(0, 12)
				IO.puts "got token"

				case Discourse.User.create({ username, email }) do
					{:ok, uid} -> 
						IO.puts "created user"
						{:ok} = Discourse.User.save_token({uid, username, token})

						Discourse.Email.send({
							"Welcome to Discourse",
							"<div>
								Welcome to Discourse, #{username}. Your login link is <a href=\"https://discourse.metal.fish/verify?username=#{username}&token=#{token}\">here</a>.
							</div>"
						}, email)

						success(%{id: uid})

					{:error, err} -> 
						IO.inspect err.code
						failed(err)
				end

			_ -> failed("body requires email and username")
		end
	end

	# endpoint for landing page
	def handle_request(%{method: :GET, path: ["api", "timelines", "recent"]}, _) do
		case Discourse.Timeline.recent(5) do
			{:ok, payload} -> success(payload)
			{:error, err} -> failed(err)
		end
	end

	# endpoint for user page
	def handle_request(%{method: :GET, path: ["api", "user", username]}, _) do
		# get all the info and return id, username, [timeline stubs]

		case Discourse.Timeline.from_username(username) do
			{:ok, timelines} -> success(timelines)
			{:error, err} -> failed(err)
		end

	end

	# endpoint to get timeline info
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

	# endpoint for getting timeline entry details and comments
	def handle_request(%{method: :GET, path: ["api", "timeline", timeline_id, "entry", entry_id]}, _) do

		{tid, _} = Integer.parse timeline_id
		{eid, _} = Integer.parse entry_id

		case Discourse.Timeline.Entry.get({tid, eid}) do
			{:ok, entry} -> success(entry)
			{:error, err} -> failed(err)
		end
	end

	# endpoint for creating comment
	def handle_request(%{method: :POST, path: ["api", "comment"], body: body}, _) do
		payload = Poison.decode!(body, [keys: :atoms])

		padded = Map.merge(%{parent_comment: nil}, payload)

		case padded do
			%{token: token, username: username, body: body, parent_entry: parent_entry, parent_comment: parent_comment} -> 
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Comment.create({uid, username, body, parent_entry, parent_comment}) do 
					{:ok, comment} -> success(comment)
					{:error, err} -> failed(err)
				end

			other -> 
				IO.inspect other
				failed("missing required fields")
		end
	end

	# endpoint for creating a timeline
	def handle_request(%{method: :POST, path: ["api", "timeline", "create"], body: body}, _) do
		payload = Poison.decode!(body, [keys: :atoms])

		case payload do
			%{title: title, username: username, token: token} -> 
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Timeline.create({title, uid}) do
					{:ok, id} -> success(%{id: id, title: title, published: false, author: uid})
					{:error, err} -> failed(err)
				end
			_ -> failed("missing required fields")
		end
	end

	# endpoint to edit top level timeline
	def handle_request(%{method: :POST, path: ["api", "timeline", id, "edit"], body: body }, _) do
		payload = Poison.decode!(body, [keys: :atoms])

		case payload do
			%{ id: id, title: title, published: published, username: username, token: token } -> 
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Timeline.edit({ id, title, published }) do
					{:ok } -> success(%{id: id, title: title, published: published, author: uid})
					{:error, err} -> failed(err)
				end
			_ -> failed("missing required fields")
		end
	end

	# endpoint for creating or updating a timeline entry
	def handle_request(%{method: :POST, path: ["api", "timeline", "entry"], body: post_body}, _) do
		payload = Poison.decode!(post_body, [keys: :atoms])

		case payload do

			%{id: id, title: title, body: body, sources: sources, imgurl: imgurl, timeline: timeline, timestamp: ts, token: token, username: username} ->
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Timeline.Entry.update({id, timeline, ts, title, body, sources, imgurl, uid}) do
					{:ok, entry} -> success(entry)
					{:error, err} -> failed(err)
				end

			%{title: title, body: body, sources: sources, imgurl: imgurl, timeline: timeline, timestamp: ts, token: token, username: username} ->
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Timeline.Entry.create({timeline, ts, title, body, sources, imgurl, uid}) do
					{:ok, entry} -> success(entry)
					{:error, err} -> failed(err)
				end

			other ->
				IO.inspect other
				failed("missing fields")

		end
	end

	def handle_request(%{method: :POST, path: ["api", "timeline", "entry", id, "delete"], body: post_body }, _) do
		payload = Poison.decode!(post_body, [keys: :atoms])

		{parsed_id, _} = Integer.parse(id)
		case payload do
			%{token: token, username: username} -> 
				{:ok, [uid | _]} = Discourse.User.from_token({username, token})
				case Discourse.Timeline.Entry.delete({parsed_id, uid}) do
					{:ok} -> success(%{})
					{:error, err} -> failed(err)
				end
			other -> 
				IO.inspect other
				failed("missing fields")
		end
	end

	def handle_request(%{method: :OPTIONS}, _) do
		response(204)
		|> set_header("access-control-allow-origin", '*')
		|> set_header("access-control-allow-methods", "GET, POST, OPTIONS")
		|> set_header("access-control-allow-headers", "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range")
	end


	def handle_request(%{} = req, _state) do
		IO.inspect req
		response(404)
		|> set_header("access-control-allow-origin", '*')
	end

	defp success(payload) do
		response(:ok)
		|> set_header("content-type", "application/json")
		|> set_header("access-control-allow-origin", '*')
		|> set_body(Poison.encode!(%{
				success: true,
				message: "",
				payload: payload 
			}, keys: :atoms!))
	end

	defp failed(%{message: message}) do
		response(:ok)
		|> set_header("content-type", "application/json")
		|> set_header("access-control-allow-origin", '*')
		|> set_body(Poison.encode!(%{
				success: false,
				message: message,
				payload: %{}
			}, keys: :atoms!))
	end

	defp failed(message) do
		response(:ok)
		|> set_header("content-type", "application/json")
		|> set_header("access-control-allow-origin", '*')
		|> set_body(Poison.encode!(%{
				success: false,
				message: message,
				payload: %{}
			}, keys: :atoms!))
	end
end