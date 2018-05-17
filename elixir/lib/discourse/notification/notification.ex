defmodule Discourse.Notification do
	@moduledoc """
	contains functions for workign with notifications
	"""

	def create({ uid, type, target_id }) do 
	end

	# comment - 0

	def CommentReply({user_id, comment_id, parent_entry, title}) do
		
		case Postgrex.query(
			Discourse.DB,
			"
			INSERT INTO Notifications (uid, type, target_id, parent_id, title)
			VALUES ($1, $2, $3, $4, $5)
			",
			[user_id, 0, comment_id, parent_entry, title]
		)
	end

	def EntryReply({user_id, parent_entry, title}) do
		
		case Postgrex.query(
			Discourse.DB,
			"
			INSERT INTO Notifications (uid, type, target_id, title)
			VALUES ($1, $2, $3, $4)
			",
			[user_id, 1, parent_entry, title]

		)
	end
end