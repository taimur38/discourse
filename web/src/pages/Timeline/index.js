import React, { Component } from 'react'
import {get, UserLink, current_user} from '../../lib'
import Loading from '../../components/Loading'
import TimelineEntry from '../../components/TimelineEntry'
import Header from '../../components/Header'

import './style.css'

// assume sorted
const extractGaps = (entries) => entries.slice(1).map((v, i) => v.timestamp - entries[i].timestamp)

const avgEventDist = 50; //px
const outlierMult = 3;

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

				console.log(timeline.entries)
				const sorted = timeline.entries.sort((a, b) => a.timestamp - b.timestamp);
				console.log('sorted')

				const gaps = extractGaps([...sorted]);

				// I should detect outliers, remove them and recompute the mean
				const mean = gaps.reduce((a, b) => a + b, 0)/gaps.length;
				const median = [...gaps].sort((a, b) => a - b)[parseInt(gaps.length / 2)];
				const span = sorted.length > 0 ? (sorted[sorted.length - 1].timestamp - sorted[0].timestamp) : false;

				const gapline = [sorted[0]].filter(x => x);

				for(let i = 1; i < sorted.length; i++) {

					const ms = gaps[i - 1] / median;
					const outlier = ms > outlierMult;
					const diff = Math.min(outlierMult, ms) * avgEventDist;

					gapline.push({ gap: true, diff, outlier, id: Math.random( )});
					gapline.push(sorted[i]);
				}

				return {...timeline, gapline }
			})
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
				this.state.timeline.gapline
					.map((e, idx) => <div className="entry-wrapper" key={e.id} style={{ height: `${e.diff}px` }}>
							<div className="date">{e.timestamp ? new Date(e.timestamp * 1000).toLocaleDateString() : false}</div>
							{ e.gap ? <div className={`v-line ${e.outlier ? "outlier" : ""}`} /> : false }
							{ e.gap ? false: <TimelineEntry {...e} /> }
						</div>)
			}
			</div>
		</div>
	}
}