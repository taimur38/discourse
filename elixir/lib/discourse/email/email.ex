defmodule Discourse.Email do
	import Swoosh.Email

	def send({subject, html}, to) do
		new()
		|> to(to)
		|> from({"Discourse", "taimur38@gmail.com"})
		|> subject(subject)
		|> html_body(html)
		|> Discourse.Email.Mailer.deliver
	end

end

defmodule Discourse.Email.Mailer do
	use Swoosh.Mailer, otp_app: :discourse
end