import React, { Component } from 'react';

class App extends Component {
	
	componentDidMount() {

		const user = localStorage.getItem("user");
		console.log(user)

	}
	render() {
		return (
			<div className="App">Hi</div>
		);
	}
}

export default App;
