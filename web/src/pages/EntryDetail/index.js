import React, { Component } from 'react'

import Header from '../../components/Header'
import Loading from '../../components/Loading'
import Comment from '../../components/Comment'

import { current_user, get, post } from '../../lib'

import './style.css'


const emptyComment = {
	body: "enter comment here",
}

export default class EntryDetail extends Component {

	// this is something that can be loaded via props
	// as a modal 
	// but also is a stand alone page....
	// make it stand alone for now.


	// /timeline/:id/entry/:entry_id

	constructor(props) {
		super(props);
		this.state = {
			loading: true,
			entry: undefined,
			comment_replies: {
				0: emptyComment
			}
		}
	}

	componentDidMount() {
		const { timeline_id, entry_id } = this.props.match.params;

		get(`/timeline/${timeline_id}/entry/${entry_id}`)
			.then(entry => this.setState({ entry, loading: false }))
			.catch(err => alert(err))
	}

	onCommentUpdate = (comment_id, e) => {
		this.setState({
			comment_replies: {
				...this.state.comment_replies,
				[comment_id]: {
					body: e.target.value
				}
			}
		})
	}

	onCommentReply = (parent_id, e) => {
		this.setState({
			comment_replies: {
				...this.state.comment_replies,
				[parent_id]: { body: "type reply here"}
			}
		})
	}

	onCommentSave = (parent_comment) => {
		console.log("SAVE", parent_comment);

		post("/comment", {
			body: this.state.comment_replies[parent_comment].body,
			parent_entry: parseInt(this.props.match.params.entry_id, 10),
			parent_comment
		}, true)
		.then(res => console.log(res))
		.then(() => this.setState({ comment_replies: { ...this.state.comment_replies, [parent_comment]: { body: ""} } }))
		.catch(alert)
	}

	onCommentCancel = (parent_id) => {
		this.setState({
			comment_replies: {
				...this.state.comment_replies,
				[parent_id]: undefined
			}
		})
	}

	render() {

		if(this.state.loading) {
			return <Loading /> 
		}

		const entry = this.state.entry;

		console.log(entry)

		return <div className="entry-detail-page">
			<Header user={current_user()} />

			<div className="entry-detail">
				<div className="top">
					<img src={entry.imgurl} alt="" />
					<div className="title">{entry.title}</div>
				</div>
				<div className="sources">
					{entry.sources.map(s => <Source key={s} url={s} />)}
				</div>
				<div className="body">{entry.body}</div>
			</div>
			<div className="comments">
				<div className="create">
					<CommentCreate update={this.onCommentUpdate.bind(this, 0)} save={this.onCommentSave.bind(this, 0)} value={this.state.comment_replies[0].body} />
				</div>
				{
					entry.comments.map(comment => <Comment comment={comment} key={comment.id} reply={this.onCommentReply.bind(this, comment.id)}>
						{ this.state.comment_replies[comment.id] ? <CommentCreate update={this.onCommentUpdate.bind(this, comment.id)} save={this.onCommentSave.bind(this, comment.id)} value={this.state.comment_replies[comment.id] ? this.state.comment_replies[comment.id].body : "" } cancel={this.onCommentCancel.bind(this, comment.id)}/> : false }
					</Comment>)
				}
			</div>
		</div>


	}
}

const Source = ({url}) => {
	const domain = new URL(url).hostname;
	return <a className="source" href={url} target="_blank">{domain}</a>
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