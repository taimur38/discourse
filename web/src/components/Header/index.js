import React from 'react'
import { Link } from 'react-router-dom'
import { UserLink, post } from '../../lib'
import Notifications from '../../pages/Notifications'

import Modal from '../Modal'
import Signup from '../Signup'
import Login from '../Login'

import './style.css'

export default class Header extends React.Component {

	constructor(props) {
		super(props)

		this.state = {
			modal: undefined,
			loading: true,
			notifications: [],
			notifications_visible: false
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

	notifClick = () => {
		this.setState({
			notifications_visible: !this.state.notifications_visible
		})
	}

	fetchNotifications = () => {
		post('/user/notifications', {}, true)
			.then(notifs =>
				{
					console.log(notifs)
					this.setState({ notifications: notifs, loading: false})
				})
			.catch(err => console.error(err))
	}

	componentDidMount() {
		this.fetchNotifications();
	}

	render() {

		const user = this.props.user;
		const loggedin = user !== null;

		//<div className="logo">Discourse</div>
		return <div className="header">
			<Link className="logo" to="/">Discourse</Link>
			<div className="right">
				{ loggedin ? 
					<UserSection user={user} notifications={this.state.notifications} loading={this.state.loading} notif_click={this.notifClick}/> :
					<LoggedOut onSignup={this.onSignup} onLogin={this.onLogin}/>
				}
			</div>

			{ this.state.notifications_visible ? <Notifications notifs={this.state.notifications} /> : false }

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

const UserSection = ({user, notifications, loading, notif_click}) => {

	return <div className="user-section">
		{ loading ? false : <div className="notif-badge" onClick={notif_click}>{notifications.filter(x => !x.read).length}</div> }
		<UserLink username={user.username} />
	</div>
}

const LoggedOut = ({onSignup, onLogin}) => {

	return <div className="logged-out">
		<div className="signup" onClick={onSignup}>Sign Up</div>
		<div className="login" onClick={onLogin}>Log In</div>
	</div>
}