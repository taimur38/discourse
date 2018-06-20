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
				undefined: emptyComment
			}
		}
	}

	componentDidMount() {
		const { timeline_id, entry_id } = this.props.match.params;

		get(`/timeline/${timeline_id}/entry/${entry_id}`)
			.then(entry => this.setState({ entry, loading: false }))
			.catch(err => alert(err))
	}

	onCommentUpdate = (...args) => {
		const comment_id = args[args.length - 2]
		const e= args[args.length - 1]

		this.setState({
			comment_replies: {
				...this.state.comment_replies,
				[comment_id]: {
					body: e.target.value
				}
			}
		})
	}

	onCommentReply = (...args) => {

		const parent_id = args[args.length - 2]
		this.setState({
			comment_replies: {
				...this.state.comment_replies,
				[parent_id]: { body: "type reply here"}
			}
		})
	}

	onCommentSave = (...args) => {
		//const parent_path = args[args.length - 2]
		const parent_comment = args[args.length - 3]

		post("/comment", {
			body: this.state.comment_replies[parent_comment].body,
			parent_entry: parseInt(this.props.match.params.entry_id, 10),
			parent_comment: parent_comment,
			timeline: parseInt(this.props.match.params.timeline_id, 10)
		}, true)
		.then(res => {
			const keys = res.path.split('/')
				.filter(x => x !== "")
				.reduce((agg, curr) => [...agg, curr, "replies"], []);

			console.log(keys)
			const comment_copy = JSON.parse(JSON.stringify(this.state.entry.comments));
			let n = comment_copy;
			for(let i = 0; i < keys.length; i++) {
				n = n[keys[i]];
			}
			n[res.id] = res;

			this.setState({ 
				comment_replies: {
					...this.state.comment_replies,
					[parent_comment]: parent_comment == undefined ? emptyComment : undefined
				},
				entry: {
					...this.state.entry,
					comments: comment_copy
				}
			})
		})
		.catch(alert)
	}

	onCommentCancel = (...args) => {
		const parent_id = args[args.length - 2];

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

		console.log(entry.timestamp)

		// create path
		return <div className="entry-detail-page">
			<Header user={current_user()} />

			<div className="entry-detail">
				<div className="top">
					<div className="img" style={{backgroundImage: `url(${entry.imgurl})`}} />
					<div className="title">{entry.title}</div>
				</div>
				<div className="date">{new Date(entry.timestamp * 1000).toLocaleDateString()}</div>
				<div className="body">{entry.body}</div>
				<div className="sources">
					{entry.sources.map(s => <Source key={s} url={s} />)}
				</div>
			</div>
			<div className="comments">
				<div className="create">
					<CommentCreate 
						update={this.onCommentUpdate.bind(this, undefined)} 
						save={this.onCommentSave.bind(this, undefined, null)} 
						value={this.state.comment_replies[undefined].body} />
				</div>
				{
					Object.values(entry.comments)
					.sort((a, b) => b.timestamp - a.timestamp)
					.map(comment => 
						<Comment 
							key={comment.id}
							comment={comment}
							reply={this.onCommentReply.bind(this, comment.id)} 
							m

							replyMap={this.state.comment_replies}
							update={this.onCommentUpdate.bind(this, comment.id)}
							save={this.onCommentSave.bind(this, comment.id, comment.path)}
							value={this.state.comment_replies[comment.id] ? this.state.comment_replies[comment.id].body : undefined}
							cancel={this.onCommentCancel.bind(this, comment.id)}
							/>)
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