import React from 'react'
import DatePicker from 'react-datepicker'
import moment from 'moment'

import 'react-datepicker/dist/react-datepicker.css'
import './style.css'

export default class CreateEntry extends React.Component {

	handleChange = (key, e) => {
		this.props.update(key, e.target.value);
	}

	onDateChange = d => {
		this.props.update("timestamp", d);
	}

	render() {

		const entry = this.props.entry;
		return <div className="create entry">

			<div className="middle">
				<input type="text" className="title" value={entry.title} onChange={this.handleChange.bind(this, "title")} />
				<div className="imgwrap">
					<img src={entry.imgurl} alt="" />
					<input type="text" className="" value={entry.imgurl} onChange={this.handleChange.bind(this, "imgurl")} />
				</div>
				<textarea type="text" className="body" value={entry.body} onChange={this.handleChange.bind(this, "body")} />
				<DatePicker 
					selected={this.props.entry.timestamp} 
					showTimeSelect 
					showMonthDropdown
					showYearDropdown
					scrollableYearDropdown
					scrollableMonthYearDropdown
					filterDate={(d) => d < moment()}
					onChange={this.onDateChange} />
			</div>
			<div className="right">
				<div className="save" onClick={this.props.save}>Save</div>
				<div className="cancel" onClick={this.props.cancel}>Cancel</div>
			</div>
		</div>
	}
}

const Source = ({url}) => {
	return <a className="source" href={url}>{url}</a>
}