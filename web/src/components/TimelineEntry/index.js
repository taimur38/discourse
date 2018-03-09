import React from 'react'

export default ({id, body, downvotes, imgurl, sources, timeline, timestamp, upvotes }) => {

	return <div className="entry">
		<div className="left">
			<img src={imgurl} href={imgurl} alt=""/>
			<div className="body">{body}</div>
			<div className="sources">{sources.map(s => <Source s key={s} />)}</div>
		</div>
	</div>
}

const Source = ({s}) => {
	return <div className="source">{s}</div>
}