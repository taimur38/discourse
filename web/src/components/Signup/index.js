import React, { Component } from 'react'
import * as lib from '../../lib'

export default class Signup extends Component {

	constructor(props) {
		super(props);
		this.state = {
			sent: false,
			username: '',
			email: ''
		}
	}

	handleChange = (key, event) => this.setState({[key]: event.target.value});
	
	handleSubmit = (event) => {
		// check email is valid
		// check username follows rules.

		const regexp = /[a-z0-9\-_]+/gi

		if(this.state.username.match(regexp).length === 1) {
			console.log(this.state, "is valid")

			lib.post("/user/create", {
				username: this.state.username,
				email: this.state.email
			})
			.then(res => {
				console.log(res);

				this.setState({
					sent: true
				})
			})
			.catch(message => alert(message))
		}
		else {
			alert("invalid username", this.state.username)
		}

		event.preventDefault();

	}

	render() {
		if(!this.state.sent)
			return (
				<div>
					<form onSubmit={this.handleSubmit}>
						<label>Username: <input type="text" value={this.state.username} onChange={this.handleChange.bind(this, "username")}/></label>
						<label>Email: <input type="text" value={this.state.email} onChange={this.handleChange.bind(this, "email")}/></label>
						<input type="submit" value="Submit" />
					</form>
				</div>
			)
		return (
			<div>{`Thanks ${this.state.username}. Check your email at ${this.state.email} for your login link`}</div>
		)
	}
}