import React, { Component } from 'react'
import * as lib from '../../lib'
import { withRouter } from 'react-router-dom'
import queryString from 'query-string'

class Verification extends Component {

	constructor(props) {
		super(props);
		console.log(props)
	}

	componentDidMount() {
		const params = queryString.parse(window.location.search);
		const token = params.token;
		const username = params.username;

		lib.get(`/user/${username}/login/${token}`)
			.then(res => {
				lib.persist("user", {...res, token});
				//redirect to the home page
				console.log('redirecting')
				this.props.history.push('/')
			})
			.catch(err => alert(err))

	}

	render() {
		return (
			<div id="verification">Verification...</div>
		)
	}
}

export default withRouter(Verification)