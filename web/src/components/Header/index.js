import React from 'react'
import { UserLink } from '../../lib'

import Modal from '../Modal'
import Signup from '../Signup'
import Login from '../Login'

import './style.css'

export default class Header extends React.Component {

	constructor(props) {
		super(props)

		this.state = {
			modal: undefined
		}

	}

	onLogin = (e) => {
		// render login modal.

		this.setState({
			modal: "login"
		})
	}

	onSignup = (e) => {
		// render signup modal
		this.setState({ modal: "signup"})
	}

	render() {

		const user = this.props.user;
		const loggedin = user !== null;

		return <div className="header">
			<div className="logo">Discourse</div>
			<div className="right">
				{ loggedin ? 
					<UserLink username={user.username}/> :
					<LoggedOut onSignup={this.onSignup} onLogin={this.onLogin}/>
				}
			</div>

			{ this.state.modal === "login" ? <Modal
				buttons={[
					{ class: "close", text: "close", callback: () => this.setState({ modal: undefined }) }
				]}>
					<Login />
				</Modal> : false
			}
			{ this.state.modal === "signup" ? <Modal 
				buttons={[
					{ class: "close", text: "close", callback: () => this.setState({ modal: undefined }) }
				]}>
					<Signup />
				</Modal> : false
			}
		</div>
	}
}

const LoggedOut = ({onSignup, onLogin}) => {

	return <div className="logged-out">
		<div className="signup" onClick={onSignup}>Sign Up</div>
		<div className="login" onClick={onLogin}>Log In</div>
	</div>
}