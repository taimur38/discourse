const baseUrl = "http://localhost:8080/api"

export function post(path, payload, authed = false) {

	if(authed) {
		payload.token = current_user().token;
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
			console.log(resp)
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

export function get(path) {

	return fetch(`${baseUrl}${path}`, {
		method: "GET",
		mode: "cors",
	})
	.then(resp => {
		console.log(resp)
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

export function current_user() {
	return localStorage.getItem("user");
}