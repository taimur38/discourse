import React, { Component } from 'react';
import * as lib from '../../lib'
import Header from '../../components/Header'
import TimelineStub from '../../components/TimelineStub'

import './style.css'

export default class HomePage extends Component {

	constructor(props) {
		super(props);

		this.state = {
			timelines: []
		}
	}

	componentDidMount() {

		lib.get("/timelines/recent")
			.then(timelines => this.setState({ timelines }))
			.catch(err => console.error(err))
	}

	render() {
		return (
			<div className="home">
				<Header user={lib.current_user()}/>
				<div className="feed">
				{
					this.state.timelines.map(tl => <TimelineStub key={tl.id} {...tl} />)
				}
				</div>
			</div>
		);
	}
}