import React from 'react'
import Loading from '../../components/Loading'
import TimelineStub from '../../components/TimelineStub'
import Header from '../../components/Header'
import { withRouter } from 'react-router-dom'

import { get, post, current_user } from '../../lib'

import './style.css'

class User extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			loading: true,
			modal: false,
			timelines: [],
			creating: false
		}
	}

	componentDidMount() {

		get(`/user/${this.props.match.params.username}`)
			.then(timelines => this.setState({ timelines, loading: false }))
			.catch(alert)

	}

	onCreate = () => {
		// redirect to creation page? or modal....(page)

		post("/timeline/create", {
			title: "Timeline Title"
		}, true)
			.then(({ id, title, author}) => {
				this.props.history.push(`/timeline/${id}/edit`)
			})
			.catch(alert)
	}

	render() {

		if(this.state.loading) { return <Loading /> }

		return <div className="user">
			<Header user={current_user()} />
			<div className="content">
				<div className="create-new" onClick={this.onCreate}>Create New Timeline</div>
				{
					this.state.timelines.map(tl => TimelineStub(tl))
				}
			</div>
		</div>
	}
}

export default withRouter(User)