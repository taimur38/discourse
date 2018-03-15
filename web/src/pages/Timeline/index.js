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
			.then(timeline => {
				const sorted = timeline.entries.sort((a, b) => a.timestamp - b.timestamp);
				const gapline = [];
				gapline.push(sorted[0])
				for(let i = 1; i < sorted.length; i++) {
					const diff = sorted[i].timestamp - sorted[i - 1].timestamp;
					console.log(sorted[i].timestamp, sorted[i-1].timestamp, diff)
					gapline.push({ gap: true, diff, id: Math.random() });
					gapline.push(sorted[i]);
				}

				return {...timeline, gapline }
			})
			.then(timeline => this.setState({ timeline, loading: false }))
			.catch(alert)
	}

	// at this point, you should render whitespaces
	// to represent time between events.
	// you can pick an absolute global time (would be fun toggle)
	// aka 1px = 1 day
	// or you can pick based on distance between first and last event
	// and event density
	// aka minimum distance between events

	render() {

		if(this.state.loading) { return <Loading /> }

		// calculate space between entries.

		return <div className="timeline">
			<Header user={current_user()}/>
			<div className="heading">
				<div className="title">{this.state.timeline.title}</div>
				<UserLink username={this.state.timeline.username} />
			</div>
			<div className="entries">
			{
				this.state.timeline.gapline
					.map(e => <div className="entry-wrapper" key={e.id} style={{ height: `${parseInt(e.diff / 60/60, 10)}px` }}>
							<div className="date">{e.timestamp ? new Date(e.timestamp * 1000).toLocaleDateString() : false}</div>
							<div className="v-line" />
							{ e.gap ? false : <div className="line" />  }
							{ e.gap ? false: <TimelineEntry {...e} /> }
						</div>)
			}
			</div>
		</div>
	}
}