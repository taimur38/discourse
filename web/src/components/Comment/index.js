import React, { Component } from 'react'
import { UserLink } from '../../lib'

import './style.css'

export default class Comment extends Component {

	render() {

		console.log(this.props)
		return <div className="comment">
			<div className="body">{this.props.comment.body}</div>
			<div className="bottom">
				<UserLink username={this.props.comment.user.username} />
				<div className="reply" onClick={this.props.reply}>Reply</div>
			</div>
			{ this.props.children }
		</div>
	}
}