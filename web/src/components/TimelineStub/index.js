import React from 'react'
import { Link } from 'react-router-dom'

export default ({ author: { username, id: uid }, created_at, id, title}) => {
	const d = new Date(created_at * 1000);

	return <div key={id} className="TimelineStub">
		<div className="title"><Link to={`/timeline/${id}`}>{title}</Link></div>
		<div className="created">{d.toLocaleString()}</div>
		<div className="author"><Link to={`/user/${username}`}>{username}</Link></div>
	</div>
}