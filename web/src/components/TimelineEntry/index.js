import React from 'react'
import './style.css'

export default class TimelineEntry extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			expanded: false
		}
	}

	render() {
		// eslint-disable-next-line
		const {id, title, body, downvotes, imgurl, sources, timeline, timestamp, upvotes } = this.props;

		const dt = new Date(timestamp * 1000);

		return <div className="entry">
			<div className="left">
				<img src={imgurl} href={imgurl} alt=""/>
			</div>
			<div className="middle">
				<div className="title">{title}</div>
				<div className="body">{body}</div>
				<div className="ts">{dt.toLocaleDateString()}</div>
				<div className="sources">{sources.map(s => <Source url={s} key={s} />)}</div>
			</div>
			<div className="right">
			</div>
		</div>
	}
}

const Source = ({url}) => {
	return <a className="source" href={url}>{url}</a>
}