import React from 'react'

import Header from '../../components/Header'
import CreateEntry from '../../components/CreateEntry'
import TimelineEntry from '../../components/TimelineEntry'

import debounce from 'debounce'

import { current_user, get, post } from '../../lib'

import './style.css'

export default class EditTimeline extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			timeline: {
				title: "Timeline Title",
				entries: []
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
				console.log(timeline)
				this.setState({ timeline })
			})
			.catch(err => alert(err))

	}

	saveTimeline = debounce(() => {
			console.log('executing savetimeline')
			post(`/timeline/${this.state.timeline.id}/edit`, {
				...this.state.timeline,
				entries: undefined
			}, true)
				.then(console.log)
				.catch(alert)
	}, 500)

	// this is for top level timeline edits -- publish and title.
	handleChange = (key, event) => {
		console.log('timeline handle change')
		this.setState({ timeline: { ...this.state.timeline, [key]: event.target.value }});

		this.saveTimeline();
	}

	onSave = ({ imgurl, title, body, timestamp, sources }) => {

		const entry = { 
			id: title, 
			timeline: this.state.timeline.id,
			author: current_user().id,
			imgurl, 
			title, 
			body,
			timestamp: timestamp.unix(),
			sources
		};

		this.setState({
			timeline: {
				...this.state.timeline,
				entries: [
					...this.state.timeline.entries,
					entry
				]
			 }
		})

		// todo: this should be saving....
		// until it returns with an ID then it saves.
		post("/timeline/entry/create", entry, true)
			.then(res => {
				console.log("saved!", res);
			})
			.catch(alert)
	}

	render() {

		return <div className="create-timeline">
			<Header user={current_user()} />
			<div className="content">
				<input id="timeline_title" type="text" value={this.state.timeline.title} onChange={this.handleChange.bind(this, "title")}/>

				<div className="explainer">Enter your Timeline Entries below</div>
				<CreateEntry save={this.onSave} />
				<div className="entries">
					{
						this.state.timeline.entries
							.sort((a, b) => a.timestamp - b.timestamp)
							.map(
							e => <TimelineEntry key={e.id} {...e} />
						)
					}
				</div>
			</div>
		</div>
	}
}