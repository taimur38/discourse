import React, { Component } from 'react'
import {get, UserLink, current_user} from '../../lib'
import Loading from '../../components/Loading'
import TimelineEntry from '../../components/TimelineEntry'
import Header from '../../components/Header'

import './style.css'

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

		get(`/timeline/${id}`)
			.then(timeline => this.setState({ timeline, loading: false }))
			.catch(alert)
	}

	render() {

		if(this.state.loading) { return <Loading /> }

		return <div className="timeline">
			<Header user={current_user()}/>
			<div className="heading">
				<div className="title">{this.state.timeline.title}</div>
				<UserLink username={this.state.timeline.username} />
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