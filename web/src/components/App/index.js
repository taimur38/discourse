import React, { Component } from 'react';
import * as lib from '../../lib'
import { Link } from 'react-router-dom'

class App extends Component {

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
			.then(timelines => this.setState({timelines}))
			.catch(err => console.error(err))
	}

	render() {
		return (
			<div className="home">
			{
				this.state.timelines.map(tl => {
					console.log(tl)
					return <div key={tl.id}>{tl.title} by {tl.author.username}</div> // timeline 
				})
			}</div>
		);
	}
}

export default App;