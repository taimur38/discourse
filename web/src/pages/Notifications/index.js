import React, { Component } from 'react';
//import * as lib from '../../lib'
//import Loading from '../../components/Loading'
import Notification from '../../components/Notification'

import './style.css'

export default class NotificationPage extends Component {

	render() {

		return <div className="notifications-container">
			<div className="top">Notifications</div>
			{
				this.props.notifs.map(n => <Notification notif={n} key={n.id}/> )
			}
		</div>
	}
}