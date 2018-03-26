import React, { Component } from 'react'

import Header from '../../components/Header'
import Loading from '../../components/Loading'

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
			comment: emptyComment
		}
	}

	componentDidMount() {
		const { timeline_id, entry_id } = this.props.match.params;

		get(`/timeline/${timeline_id}/entry/${entry_id}`)
			.then(entry => this.setState({ entry, loading: false }))
			.catch(err => alert(err))
	}

	onCommentUpdate = (e) => {
		this.setState({
			comment: {
				body: e.target.value
			}
		})
	}

	onCommentSave = (parent_comment) => {
		console.log("SAVE", parent_comment);

		post("/comment", {
			body: this.state.comment.body,
			parent_entry: parseInt(this.props.match.params.entry_id, 10),
			parent_comment
		}, true)
		.then(res => console.log(res))
		.catch(alert)
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
					<CommentCreate update={this.onCommentUpdate} save={this.onCommentSave.bind(this, undefined)} value={this.state.comment.body} />
				</div>
			</div>
		</div>


	}
}

const Source = ({url}) => {
	const domain = new URL(url).hostname;
	return <a className="source" href={url} target="_blank">{domain}</a>
}

const CommentCreate = ({ update, save, value }) => {

	return <div className="comment-create">
		<textarea className="comment-create" value={value} onChange={update} />
		<div className="submit" onClick={save}>Submit</div>
	</div>
}