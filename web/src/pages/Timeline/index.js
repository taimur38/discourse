import React, { Component } from 'react'
import * as lib from '../../lib'
import TimelineEntry from '../../components/TimelineEntry'

export default class Timeline extends Component {

	constructor(props) {
		super(props);
		this.state = {
			timeline: { },
			loading: true
		}
	}

	componentDidMount() {

		const id = this.props.match.params.id;

		lib.get(`/timeline/${id}`)
			.then(timeline => this.setState({ timeline, loading: false }))
			.catch(alert)
	}
	render() {

		if(this.state.loading) {
			return <div>Loading....</div>
		}

		return <div className="timeline">
			<div className="heading">
				<div className="title">{this.state.timeline.title}</div>
				<div className="author">{this.state.timeline.username}</div>
			</div>
			<div className="entries">
			{
				this.state.timeline.entries
					.sort((a, b) => a.timestamp - b.timestamp)
					.map(e => <TimelineEntry key={e.id} {...e} />)
			}
			</div>
		</div>
	}
}