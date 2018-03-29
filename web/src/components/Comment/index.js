import React, { Component } from 'react'
import { UserLink } from '../../lib'

import './style.css'

export default class Comment extends Component {

	render() {

		return <div className="comment">
			<div className="body">{this.props.comment.body}</div>
			<div className="bottom">
				<UserLink username={this.props.comment.user.username} />
				<div className="reply" onClick={this.props.reply}>Reply</div>
			</div>

			{
				this.props.value !== undefined ? 
					<CommentCreate 
						update={this.props.update}
						save={this.props.save}
						value={this.props.value}
						cancel={this.props.cancel}
					/> : false
			}
			<div className="replies">
				{
					Object.values(this.props.comment.replies)
						.map(comment => <Comment 
								key={comment.id}
								comment={comment} 
								reply={this.props.reply.bind(this, comment.id)}

								replyMap={this.props.replyMap}
								update={this.props.update.bind(this, comment.id)}
								save={this.props.save.bind(this, comment.id, comment.path)}
								value={this.props.replyMap[comment.id] ? this.props.replyMap[comment.id].body : undefined}
								cancel={this.props.cancel.bind(this, comment.id)}
							/>)
				}
			</div>
		</div>
	}
}

const CommentCreate = ({ update, save, value, cancel=undefined}) => {

	return <div className="comment-create">
		<textarea className="comment-create" value={value} onChange={update} />
		<div className="bottom">
			<div className="save" onClick={save}>Submit</div>
			{ cancel ? <div className="cancel" onClick={cancel}>Cancel</div> : false }
		</div>
	</div>
}