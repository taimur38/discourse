import React from 'react'

import Header from '../../components/Header'
import CreateEntry from '../../components/CreateEntry'
import TimelineEntry from '../../components/TimelineEntry'

import moment from 'moment'

import debounce from 'debounce'

import { current_user, is_owner, get, post } from '../../lib'

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
				title: "Timeline Title",
				entries: {}
			},
			editEntry: emptyEntry,
			saving: false
		}
	}

	componentDidMount() {
		if(current_user() == null) {
			alert("please log in to edit a timeline");
		}

		const id = this.props.match.params.id;

		get(`/timeline/${id}`)
			.then(timeline => {
				if(!is_owner(timeline.userid)) {
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

	// this deals with the save button
	onSave = async () => {

		this.setState({ saving: true });

		try {
			const res = await post("/timeline/entry", {
				...this.state.editEntry, 
				timestamp: this.state.editEntry.timestamp.unix(),
				timeline: this.state.timeline.id,

			}, true);

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

	onEdit = (entry) => {
		this.setState({
			editEntry: {
				...entry,
				timestamp: moment(entry.timestamp * 1000)
			}
		})
	}

	onDelete = async (entry) => {

		/* bug report
		const { [entry.id]: gone, ...entries } = this.state.timeline.entries;

		console.log(gone == entry) // true
		console.log(entries) // still includes entry
		*/

		this.setState({saving: true})
		try {
			await post(`/timeline/entry/${entry.id}/delete`, {}, true);

			let entries = JSON.parse(JSON.stringify(this.state.timeline.entries))
			delete entries[entry.id];

			this.setState({
				timeline: {
					...this.state.timeline,
					entries
				},
				saving: false
			})
		}
		catch(e) {
			alert(e)
			this.setState({saving: false})
		}
	}

	onCancel = () => {
		this.setState({
			editEntry: emptyEntry
		})
	}

	onPublish = () => {

		this.setState({
			timeline: {
				...this.state.timeline,
				published: !this.state.timeline.published
			}
		})

		this.saveTimeline();

	}

	render() {

		return <div className="create-timeline">
			<Header user={current_user()} />
			<div className="content">
				<div className="topper">
					<input id="timeline_title" type="text" value={this.state.timeline.title} onChange={this.handleChange.bind(this, "title")}/>
					<div className="button publish" onClick={this.onPublish}>{this.state.timeline.published ? "Unpublish" : "Publish"}</div>
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