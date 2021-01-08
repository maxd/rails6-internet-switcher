import {Controller} from "stimulus"

export default class extends Controller {
    connect() {
        this.loadButtonsStates();
    }

    toggleInternet(event) {
        const button = event.target;

        const id = button.dataset.id
        const enable = !("isInternetEnabled" in button.dataset)

        const params = {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
            },
            body: JSON.stringify({id, enable})
        }

        fetch("/api/internet/enable", params)
            .then(response => {
                if (!response.ok)
                    throw new Error(`Can not disable/enable Internet for '${id}' button!`)
                return response.json()
            })
            .then(data => {
                this.setButtonState(button, data.enabled)
                this.redrawButton(button)
            })
            .catch(error => alert(error))
    }

    loadButtonsStates() {
        const buttonSelector = '[data-controller="internet"] [data-action="internet#toggleInternet"]'
        const buttons = document.querySelectorAll(buttonSelector)
        buttons.forEach(button => {
            this.loadButtonState(button)
        })
    }

    loadButtonState(button) {
        const id = button.dataset.id

        const params = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            },
        }

        fetch("/api/internet/status?" + new URLSearchParams({id}), params)
            .then(response => {
                if (!response.ok)
                    throw new Error(`Can not load '${id}' button state!`)
                return response.json()
            })
            .then(data => {
                this.setButtonState(button, data.enabled)
                this.redrawButton(button)
            })
            .catch(error => {
                button.textContent = error
                button.disabled = true
            })
    }

    setButtonState(button, enabled) {
        if (enabled)
            button.setAttribute('data-is-internet-enabled', '')
        else
            button.removeAttribute('data-is-internet-enabled')
    }

    redrawButton(button) {
        const name = button.dataset.name
        const isInternetEnabled = "isInternetEnabled" in button.dataset

        button.disabled = false
        button.textContent = `${name} - Internet ${isInternetEnabled ? 'Enabled' : 'Disabled'}`
        button.classList.remove('red', 'green')
        button.classList.add(isInternetEnabled ? 'green' : 'red')
    }
}
