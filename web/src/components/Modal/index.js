import React from 'react'
import './style.css'

// a modal should take in another component, add buttons and callback.

const Modal = (props) => {
	return (
		<div className="modal-backdrop">
			<div className="buttons">
			{
				props.buttons.map(btn => <div key={btn.class} className={btn.class} onClick={btn.callback}>{btn.text}</div>)
			}
			</div>
			<div className="modal">
				{props.children}
			</div>
		</div>
	)
}

export default Modal;