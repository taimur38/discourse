import React from 'react'
import './style.css'
import { Link } from 'react-router-dom'

import CommentImg from './comment.svg'

export default class TimelineEntry extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			expanded: false
		}
	}

	toggleExpand = () => {
		this.setState({ expanded: !this.state.expanded })
	}

	render() {
		// eslint-disable-next-line
		const {id, title, body, downvotes, imgurl, sources, timeline, timestamp, upvotes, userid} = this.props;

		return <div className={`entry ${this.state.expanded ? "expanded" : ""}`}>
			<div className="left">
				<img src={imgurl} alt=""/>
			</div>
			<div className="middle">
				<div className="title">{title}</div>
			</div>
			<div className="right">
				<Link to={`/timeline/${timeline}/entry/${id}`}>
					<img alt="comment" className="comment" src={CommentImg} />
				</Link>
			</div>
		</div>
	}
}

/*
const Source = ({url}) => {
	const domain = new URL(url).hostname;
	return <a className="source" href={url}>{domain}</a>
}
*/