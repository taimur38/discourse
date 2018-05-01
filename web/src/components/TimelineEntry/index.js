import React from 'react'
import './style.css'
import { withRouter } from 'react-router-dom'

import CommentImg from './comment.svg'

class TimelineEntry extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			expanded: false
		}
	}

	toggleExpand = () => {
		this.setState({ expanded: !this.state.expanded })
	}

	onEntryClick = () => {

		const {history, timeline, id} = this.props;
		history.push(`/timeline/${timeline}/entry/${id}`)
	}

	render() {
		// eslint-disable-next-line
		const {id, title, body, downvotes, imgurl, sources, timeline, timestamp, upvotes, userid, num_comments} = this.props;

		//<Link to={`/timeline/${timeline}/entry/${id}`}>
		return <div className={`entry ${this.state.expanded ? "expanded" : ""}`} onClick={this.onEntryClick}>
			<div className="left">
				<div className="img" style={{backgroundImage: `url(${imgurl})` }} />
			</div>
			<div className="middle">
				<div className="title">{title}</div>
			</div>
			<div className="right">
				<div>
					<div className="comment-img" style={{backgroundImage: `url(${CommentImg})`}} />
					<div className="comment-num">{num_comments}</div>
				</div>
			</div>
		</div>
	}
}

export default withRouter(TimelineEntry)