import React, { Component } from 'react'

export default class Login extends Component{
	constructor(props) {
		super(props);
		this.state = {
			username: '',
			email: ''
		}
	}

	handleChange = (key, event) => this.setState({[key]: event.target.value});
	
	handleSubmit = (event) => {
		// check email is valid
		// check username follows rules.
		
	}

	render() {
		return (
			<div>
				<form onSubmit={this.handleSubmit}>
					<label>Username: <input type="text" value={this.state.username} onChange={this.handleChange.bind(this, "username")}/></label>
					<label>Email: <input type="text" value={this.state.email} onChange={this.handleChange.bind(this, "email")}/></label>
					<input type="submit" value="Submit" />
				</form>
			</div>
		)
	}
}