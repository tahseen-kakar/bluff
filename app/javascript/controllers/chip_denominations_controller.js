import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container", "denomination"]

  connect() {
    // Add initial denomination field if none exist
    if (this.denominationTargets.length === 0) {
      this.addDenomination()
    }
  }

  addDenomination(event) {
    // Clone the template content
    const content = this.templateTarget.content.cloneNode(true)
    
    // Add the new denomination fields to the container
    this.containerTarget.appendChild(content)
  }

  removeDenomination(event) {
    const denomination = event.target.closest('[data-chip-denominations-target="denomination"]')
    
    // Only remove if it's not the last denomination
    if (this.denominationTargets.length > 1) {
      denomination.remove()
    }
  }
} 