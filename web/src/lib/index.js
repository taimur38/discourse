import React from 'react'
import { Link } from 'react-router-dom'

const baseUrl = "https://discourse-backend.metal.fish/api"
//const baseUrl = "http://192.168.0.27:8080/api"
//const baseUrl = "http://192.168.0.98:8080/api"
//const baseUrl = "http://192.168.1.115:8080/api"
//const baseUrl = "http://172.31.99.232:8080/api"
//const baseUrl = "http://localhost:8080/api"

export function post(path, payload, authed = false) {

	if(authed) {

		if(current_user() == null) {
			return Promise.reject("not authenticated");
		}

		payload.token = current_user().token;
		payload.username = current_user().username;
	}

	return fetch(`${baseUrl}${path}`, {
		body: JSON.stringify(payload),
		method: 'POST',
		mode: 'cors',
		headers: new Headers({
			'Content-Type': 'application/json'
		})
	})
		.then(resp => { 
			return resp.json()
		})
		.then(json => {
			const parsed =  {
				success: false,
				payload: {},
				message: "", 
				...json
			}

			if(!parsed.success) {
				throw new Error(parsed.message)
			}
			else {
				return parsed.payload;
			}
		})
}

export function get(path, authed = false) {

	return fetch(`${baseUrl}${path}`, {
		method: "GET",
		mode: "cors",
	})
	.then(resp => {
		return resp.json()
	})
	.then(json => {
		const parsed = {
			success: false,
			payload: {},
			message: "",
			...json
		}

		if(!parsed.success) {
			throw new Error(parsed.message)
		}
		else {
			return parsed.payload;
		}
	})
}

export function persist(key, value) {
	localStorage.setItem(key, JSON.stringify(value));
}

export function localeGet(key) {
	JSON.parse(localStorage.getItem(key))
}

export function is_owner(uid) {
	return current_user() && current_user().id == uid;
}

export function current_user() {
	return JSON.parse(localStorage.getItem("user"));
}

export function UserLink({username, ...props}) {
	return <Link to={`/user/${username}`} className="user">{username}</Link>
}

export function TimelineLink({id, title, ...props}) {
	return <Link to={`/timeline/${id}`} className="timeline-link">{title}</Link>
}