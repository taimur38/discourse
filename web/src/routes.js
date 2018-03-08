import React from 'react'
import { BrowserRouter, Route, Switch} from 'react-router-dom'

import App from './components/App'
import Signup from './components/Signup'
import Login from './components/Login'
import Verify from './pages/Verification'

export default (props) => (
	<BrowserRouter>
		<Switch>
			<Route exact path="/" component={App} />
			<Route path="/signup" component={Signup} />
			<Route path="/login" component={Login} />
			<Route path="/verify" component={Verify} />
		</Switch>
	</BrowserRouter>
)