import React, { Component } from 'react'
import * as lib from '../../lib'

export default class Login extends Component {

	constructor(props) {
		super(props);
		this.state = {
			sent: false,
			email: ''
		}
	}

	handleChange = (key, event) => this.setState({[key]: event.target.value});
	
	handleSubmit = (event) => {
		// check email is valid

		lib.post("/user/login", {
			email: this.state.email
		})
		.then(res => {
			console.log(res)

			this.setState({
				sent: true
			})
		})
		.catch(message => alert(message))

		event.preventDefault();

	}

	render() {
		if(!this.state.sent)
			return (
				<div>
					<form onSubmit={this.handleSubmit}>
						<label>Email: <input type="text" value={this.state.email} onChange={this.handleChange.bind(this, "email")}/></label>
						<input type="submit" value="Submit" />
					</form>
				</div>
			)
		return (
			<div>{`Check your email at ${this.state.email} for your login link`}</div>
		)
	}
}