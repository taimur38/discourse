import React from 'react'

import Header from '../../components/Header'
import CreateEntry from '../../components/CreateEntry'
import TimelineEntry from '../../components/TimelineEntry'

import moment from 'moment'
import debounce from 'debounce'

import { current_user, get, post, UserLink } from '../../lib'

import './style.css'


const emptyEntry = {
	imgurl: "http://via.placeholder.com/120x120",
	title: "Entry Title",
	body: "Write a description of this event",
	timestamp: moment(),
	sources: []
}

export default class EditTimeline extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			timeline: {
				id: -1,
				title: "Timeline Title",
				entries: {},
				published: false,
				author: { username: "", id: 0 },
				editors: []
			},
			editEntry: emptyEntry,
			saving: false,
			editorSearch: {
				active: false,
				val: "",
				potentialUsers: []
			}
		}
	}

	componentDidMount() {
		if(current_user() == null) {
			alert("please log in to edit a timeline");
		}

		const id = this.props.match.params.id;

		get(`/timeline/${id}`)
			.then(timeline => {
				if(!timeline.editors.some(x => current_user() && current_user().id === x.id)) {
					alert("hey, this isn't your timeline")
				}
				else {
					this.setState({ 
						timeline: {
							...timeline,
							entries:  timeline.entries.reduce((acc, curr) => { 
									acc[curr.id] = curr; 
									return acc; 
								}, {})
						}
					})
				}
			})
			.catch(err => alert(err))
	}

	saveTimeline = debounce(() => {
			post(`/timeline/${this.state.timeline.id}/edit`, {
				...this.state.timeline,
				entries: undefined
			}, true)
				.then(console.log)
				.catch(alert)
	}, 500)

	// this is for top level timeline edits -- publish and title.
	handleChange = (key, event) => {
		this.setState({ timeline: { ...this.state.timeline, [key]: event.target.value }});

		this.saveTimeline();
	}

	// this handles editEntry updates
	onUpdate = (key, val) => {
		this.setState({
			editEntry: {
				...this.state.editEntry,
				[key]: val
			}
		})
	}

	onTagClose = (editor) => {
		post(`/timeline/${this.state.timeline.id}/editor/remove`, {editor_id: editor.id}, true)
			.then(resp => {
				this.setState({
					timeline: {
						...this.state.timeline,
						editors: resp.editors
					} 
				})
			})
			.catch(err => alert(err))

		// remove from this.state.editors
		// send request to removeEditors on server
	}


	// this deals with the save button
	onSave = async () => {

		this.setState({ saving: true });

		try {
			const res = await post("/timeline/entry", {
				...this.state.editEntry, 
				timestamp: this.state.editEntry.timestamp.unix(),
				timeline: this.state.timeline.id,

			}, true);

			console.log("SAVED")

			this.setState({
				timeline: {
					...this.state.timeline,
					entries: {
						...this.state.timeline.entries,
						[res.id]: res
					},
				},
				editEntry: emptyEntry,
				saving: false
			})

		}
		catch(ex) {
			console.error(ex);
			alert(ex);
			this.setState({
				saving: false
			})
		}
	}

	publish = () => {
		this.setState({
			timeline: {
				...this.state.timeline,
				published: true
			}
		}, this.saveTimeline)
	}

	onEdit = (entry) => {
		this.setState({
			editEntry: {
				...entry,
				timestamp: moment(entry.timestamp * 1000)
			}
		})

		document.documentElement.scrollTo(0, 0)
	}

	editorAdd = (event) => {
		this.setState({
			editorSearch: {
				...this.state.editorSearch,
				val: event.target.value
			}
		})

		if(event.target.value.length > 0) {
			this.searchUsers();
		}
	}

	searchUsers = debounce(() => {
		if(this.state.editorSearch.val.length === 0) {
			return;
		}

		post(`/user/lookup/${this.state.editorSearch.val}`, {}, true)
		.then(res => {
			console.log(res)
			this.setState({
				editorSearch: {
					...this.state.editorSearch,
					potentialUsers: res
				}
			})
		})
		.catch(err => console.error(err))
	})

	searchClick = (user) => {
		post(`/timeline/${this.state.timeline.id}/editor/add`, {editor_id: user.id}, true)
		.then(res => {
			console.log(res)
			this.setState({ timeline: {
				...this.state.timeline,
				editors: res.editors
			}})
		})
		.catch(err => console.error(err))
	}

	editorRemove = (user) => {
		console.log(user)
	}

	onDelete = (entry) => {

		/* bug report
		const { [entry.id]: gone, ...entries } = this.state.timeline.entries;


		console.log(gone == entry) // true
		console.log(entries) // still includes entry
		*/

		let entries = JSON.parse(JSON.stringify(this.state.timeline.entries))
		delete entries[entry.id];

		this.setState({
			timeline: {
				...this.state.timeline,
				entries
			}
		})
	}

	onCancel = () => {
		this.setState({
			editEntry: emptyEntry
		})
	}

	render() {

		return <div className="create-timeline">
			<Header user={current_user()} />
			<div className="content">
				<input id="timeline_title" type="text" value={this.state.timeline.title} onChange={this.handleChange.bind(this, "title")} />

				<div className="under-title">
					{ !this.state.timeline.published ? <div className="publish" onClick={this.publish}>Publish</div> : <div>This timeline is published publicly</div>}
				</div>
				<div className="editors">
					<div className="editors-text">Timeline Editors:</div>
					{ 
						this.state.timeline.editors.map(u => <TagWrapper onClose={this.onTagClose.bind(this, u)}>
							<div className="editor" key={u.id}>
								<UserLink username={u.username} />
							</div>
						</TagWrapper>)
					}
				</div>
				<div className="editor-search">
					<div className="editor-search-txt">Add Editor:</div>
					<input type="text" className="add-editor" value={this.state.editorSearch.val} onChange={this.editorAdd} />
				</div>
				<div className="search-results">
				{
					this.state.editorSearch.potentialUsers.map(x => <div className="search-result" onClick={this.searchClick.bind(this, x)}>{x.username}</div>)
				}
				</div>
				<div className="explainer">Enter your Timeline Entries below</div>
				{ this.state.saving ? <div>Saving....</div> : <CreateEntry save={this.onSave} update={this.onUpdate} entry={this.state.editEntry} cancel={this.onCancel} /> }
				<div className="entries">
					{
						Object.keys(this.state.timeline.entries)
							.map(k => this.state.timeline.entries[k])
							.sort((a, b) => a.timestamp - b.timestamp)
							.map( e => <div className="entry-wrap" key={e.id}>
								<TimelineEntry {...e} />
								<Edit onEdit={this.onEdit.bind(this, e)} onDelete={this.onDelete.bind(this, e)}/>
							</div>)
					}
				</div>
			</div>
		</div>
	}
}

const Edit = ({ onEdit, onDelete }) => <div className="owner-wrap">
	<div className="edit" onClick={onEdit} >Edit</div>
	<div className="delete" onClick={onDelete} >Delete</div>
</div>

const TagWrapper = ({ children, onClose}) => <div className="tag">
	{children}
	<div className="closey" onClick={onClose}>x</div>
</div>