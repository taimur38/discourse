import React from 'react'
import { BrowserRouter, Route, Switch } from 'react-router-dom'

// all these should go away
import Signup from './components/Signup'
import Login from './components/Login'

import Home from './pages/Home'
import Verify from './pages/Verification'
import User from './pages/User'
import Timeline from './pages/Timeline'

export default (props) => (
	<BrowserRouter>
		<Switch>
			<Route exact path="/" component={Home} />
			<Route path="/verify" component={Verify} />
			<Route path="/timeline/:id" component={Timeline} />
			<Route path="/user/:id" component={User} />


			<Route path="/signup" component={Signup} />
			<Route path="/login" component={Login} />

		</Switch>
	</BrowserRouter>
)