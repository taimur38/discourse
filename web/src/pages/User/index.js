import React from 'react'
import Loading from '../../components/Loading'
import TimelineStub from '../../components/TimelineStub'
import * as lib from '../../lib'

export default class User extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			loading: true,
			timelines: []
		}
	}

	componentDidMount() {

		lib.get(`/user/${this.props.match.params.username}`)
			.then(timelines => this.setState({ timelines, loading: false }))
			.catch(alert)

	}

	render() {

		if(this.state.loading) { return <Loading /> }

		return <div className="user">
		{
			this.state.timelines.map(tl => TimelineStub(tl))
		}
		</div>
	}
}