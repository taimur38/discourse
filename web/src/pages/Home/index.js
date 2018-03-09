import React, { Component } from 'react';
import * as lib from '../../lib'
import TimelineStub from '../../components/TimelineStub'

export default class HomePage extends Component {

	constructor(props) {
		super(props);

		this.state = {
			timelines: []
		}
	}

	componentDidMount() {

		const user = localStorage.getItem("user");
		console.log(user)

		lib.get("/timelines/recent")
			.then(timelines => this.setState({ timelines }))
			.catch(err => console.error(err))
	}

	render() {
		return (
			<div className="home">
			{
				this.state.timelines.map(tl => <TimelineStub key={tl.id} {...tl} />)
			}</div>
		);
	}
}