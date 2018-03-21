import React from 'react'
import { Link } from 'react-router-dom'
import { UserLink, TimelineLink, current_user } from '../../lib'

import './style.css'

export default ({ author: { username, id: uid }, created_at, id, title}) => {
	const d = new Date(created_at * 1000);

	return <div key={id} className="timeline-stub">

		<div className="left" />
		<div className="middle">
			<div className="top">
				<TimelineLink id={id} title={title} />
			</div>
			<div className="bottom">
				<span>{`submitted ${dateDiff(d)} by `}</span>
				<UserLink username={username} />
			</div>
		</div>
		<div className="right">
			{ current_user().id == uid ? <Link className="edit" to={`/timeline/${id}/edit`}>Edit</Link> : false }
		</div>
	</div>
}

const dateDiff = (d) => {
	let diff = parseInt((Date.now() - d)/1000, 10);
	console.log(diff)

	if(diff < 60) {
		return `${diff} seconds ago`
	}

	diff = parseInt(diff/60, 10); 
	if(diff < 60) {
		return `${diff} minutes ago`
	}

	diff = parseInt(diff / 60, 10)
	if(diff < 24) {
		return `${diff} hours ago`
	}

	diff = parseInt(diff / 24, 10)
	if(diff < 365) {
		return `${diff} days ago`
	}

	diff = parseInt(diff / 365, 10)
	return `${diff} years ago`
};