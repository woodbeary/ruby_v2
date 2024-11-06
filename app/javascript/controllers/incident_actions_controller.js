import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.logAction.bind(this))
  }

  logAction(event) {
    const action = event.currentTarget.dataset.action
    const message = event.currentTarget.dataset.logMessage
    
    if (message) {
      this.broadcastToTerminal(message)
    }
  }

  broadcastToTerminal(message) {
    const event = new CustomEvent("terminal:log", {
      detail: { message },
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }
} 