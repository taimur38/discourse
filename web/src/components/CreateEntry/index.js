import React from 'react'
import Modal from '../Modal'

import DatePicker from 'react-datepicker'
import moment from 'moment'

import 'react-datepicker/dist/react-datepicker.css'

const defaultState = {
	imgurl: "http://via.placeholder.com/120x120",
	title: "Entry Title",
	body: "Write a description of this event",
	timestamp: moment(),
	sources: []
	
}
export default class CreateEntry extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			modal: false,
			entry: defaultState
		};
	}

	handleChange = (key, e) => {
		this.setState({
			entry: {
				...this.state.entry,
				[key]: e.target.value
			}
		})
	}

	onSave = () => {
		// call addEntry to props with state.
		this.props.save(this.state.entry);
		this.setState({ entry: defaultState })
	}
	//input type="text" className="timestamp" value={entry.timestamp} onChange={this.handleChange.bind(this, "timestamp")} />				<				<div className="sources">{entry.sources.map(s => <Source url={s} key={s} />) />div>

	onImgClick = () => {
		this.setState({
			modal: true
		})
	}

	dateChange = (d) => {
		this.setState({
			entry: {
				...this.state.entry,
				timestamp: d
			}
		})
	}

	render() {

		const entry = this.state.entry;
		return <div className="create entry">

			{this.state.modal ? <Modal buttons={[
				{ class: "close", text: "close", callback: () => this.setState({ modal: false }) }
			]}><ImgEntry handleChange={this.handleChange.bind(this, "imgurl")} value={entry.imgurl} save={() => this.setState({ modal: false })}/> </Modal> : false}
			<div className="left">
				<img src={entry.imgurl} alt="" onClick={this.onImgClick}/>
			</div>
			<div className="middle">
				<input type="text" className="title" value={entry.title} onChange={this.handleChange.bind(this, "title")} />
				<textarea type="text" className="body" value={entry.body} onChange={this.handleChange.bind(this, "body")} />
				<DatePicker 
					selected={this.state.entry.timestamp} 
					showTimeSelect 
					showMonthDropdown
					showYearDropdown
					filterDate={(d) => d < moment()}
					onChange={this.dateChange} />
			</div>
			<div className="right">
				<div className="save" onClick={this.onSave}>Save</div>
			</div>
		</div>
	}
}

const ImgEntry = ({handleChange, value, save}) => {
	return <div>
		<input type="text" className="" value={value} onChange={handleChange} />
		<div className="save" onClick={save}>Save</div>
	</div>
}
const Source = ({url}) => {
	return <a className="source" href={url}>{url}</a>
}