defmodule Discourse.MixProject do
	use Mix.Project

	def project do
	[
		app: :discourse,
		version: "0.1.0",
		elixir: "~> 1.6",
		start_permanent: Mix.env() == :prod,
		deps: deps()
	]
	end

  # Run "mix help compile.app" to learn about applications.
	def application do
	[
		extra_applications: [:logger],
		mod: {Discourse.Application, []}
	]
	end

	# Run "mix help deps" to learn about dependencies.
	defp deps do
	[
		{:poison, "~> 3.0"},
		{:postgrex, "~>0.13.3"},
		{:uuid, "~> 1.1"},
		{:ace, "~> 0.15.10"},
		{:swoosh, "~> 0.13"}
		# {:dep_from_hexpm, "~> 0.3.0"},
		# {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
	]
	end
end
