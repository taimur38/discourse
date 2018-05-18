import React, { Component } from 'react'
import { Link } from 'react-router-dom'

import './style.css'

export default Notification = ({notif}) => {

	if(this.props.notif.type == "CommentReply") {
		return <CommentNotif notif={notif} />
	}

	if(this.props.notif.type == "EntryReply") {
		return <EntryNotif notif={notif} />
	}
}

const CommentNotif = ({notif}) => {
	return <div className="comment notification">
		<Link to={`/timeline/${}/entry/${}`}>{notif.title}</Link>
	</div>
}

const EntryNotif = ({notif}) => {
	return <div className="entry notification">
	</div>
}