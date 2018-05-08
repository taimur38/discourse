import React from 'react'
import './style.css'
import { withRouter, Link } from 'react-router-dom'

import CommentImg from './comment.svg'

class TimelineEntry extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			expanded: false
		}
		this.entry_elem = React.createRef();
	}

	toggleExpand = () => {
		this.setState({ expanded: !this.state.expanded })
	}

	onEntryClick = () => {

		const {history, timeline, id} = this.props;
		console.log(history)
		console.log("scroll", document.body.offsetHeight)
		history.push(`/timeline/${timeline}/entry/${id}`, { position: document.body.offsetHeight })
	}

	render() {
		// eslint-disable-next-line
		const {id, title, body, downvotes, imgurl, sources, timeline, timestamp, upvotes, userid, num_comments} = this.props;

		//<Link to={`/timeline/${timeline}/entry/${id}`}>
		// onClick={this.onEntryClick}
		return <Link to={`/timeline/${timeline}/entry/${id}`} className="entry-wrapper-link">
		<div className={`entry ${this.state.expanded ? "expanded" : ""}`}  ref={this.entry_elem}>
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
		</Link>
	}
}

export default withRouter(TimelineEntry)