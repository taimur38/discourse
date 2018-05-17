defmodule Discourse.Application do
	# See https://hexdocs.pm/elixir/Application.html
	# for more information on OTP Applications
	@moduledoc false

	use Application

	def start(_type, _args) do
		import Supervisor.Spec, warn: false
		# List all child processes to be supervised
		children = [
			worker(Discourse.Server, [%{}]),
			{ 
				Postgrex,
					name: Discourse.DB, 
					hostname: "localhost",
					username: "postgres",
					password: "postgres",
					database: "postgres",
					extensions: [ Postgrex.Extensions.JSON ] 
			}
		# Starts a worker by calling: Discourse.Worker.start_link(arg)
		# {Discourse.Worker, arg},
		]

		# See https://hexdocs.pm/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Discourse.Supervisor]
		Supervisor.start_link(children, opts)
	end
end
