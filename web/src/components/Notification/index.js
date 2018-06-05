import React from 'react'
import { Link } from 'react-router-dom'

import * as lib from '../../lib'

import './style.css'

export default ({notif}) => {

	if(notif.type === "CommentReply") {
		return <CommentNotif notif={notif} />
	}

	if(notif.type === "EntryReply") {
		return <EntryNotif notif={notif} />
	}

	return <div>Error</div>
}

const CommentNotif = ({notif}) => {
	return <div className={`comment-reply notification ${notif.read ? "read" : "unread"}`}>
		<Link to={`/timeline/${notif.parent_id}/entry/${notif.target_id}`} onClick={markRead(notif)}>{notif.title}</Link>
	</div>
}

const EntryNotif = ({notif}) => {
	return <div className={`entry-reply notification ${notif.read ? "read" : "unread"}`}>
		<Link to={`/timeline/${notif.parent_id}/entry/${notif.target_id}`} onClick={markRead(notif)}>{notif.title}</Link>
	</div>
}

const markRead = notif => () => {
	console.log('clicked on', notif)

	lib.post("/user/notifications/read", notif, true)
		.then(() => console.log('marked read'))
		.catch(err => console.error(err))

}