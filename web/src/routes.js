import React from 'react'
import { BrowserRouter, Route, Switch } from 'react-router-dom'

// all these should go away
import Signup from './components/Signup'
import Login from './components/Login'

import Home from './pages/Home'
import Verify from './pages/Verification'
import User from './pages/User'
import Timeline from './pages/Timeline'
import EditTimeline from './pages/EditTimeline'
import EntryDetail from './pages/EntryDetail'

export default (props) => (
	<BrowserRouter>
		<Switch>
			<Route exact path="/" component={Home} />
			<Route exact path="/home" component={Home} />
			<Route path="/verify" component={Verify} />
			<Route path="/timeline/:id/edit" component={EditTimeline} />
			<Route path="/timeline/:timeline_id/entry/:entry_id" component={EntryDetail} />
			<Route path="/timeline/:id" component={Timeline} />
			<Route path="/user/:username" component={User} />


			<Route path="/signup" component={Signup} />
			<Route path="/login" component={Login} />

		</Switch>
	</BrowserRouter>
)