import React from 'react'
import { BrowserRouter, Route, Switch} from 'react-router-dom'

import App from './components/App'
import Login from './components/Login'

export default (props) => (
	<BrowserRouter>
		<Switch>
			<Route exact path="/" component={App} />
			<Route path="/login" component={Login} />
		</Switch>
	</BrowserRouter>
)