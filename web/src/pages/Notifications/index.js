import React, { Component } from 'react';
import * as lib from '../../lib'
import Header from '../../components/Header'
import Loading from '../../components/Loading'

import './style.css'

export default class NotificationPage extends Component {

	constructor(props) {
		super(props);

		this.state = {
			notifications: [],
			loading: true
		}
	}

	fetchNotifications = () => {
		lib.post('/user/notifications', {}, true)
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

		if(this.state.loading) {
			return <Loading />
		}

		return <div>
			Notifications:
			{
				this.state.notifications.map(n => <div>{n.title}</div> )
			}
		</div>
	}
}