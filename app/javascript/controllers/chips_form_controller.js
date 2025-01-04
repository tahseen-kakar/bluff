import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chips-form"
export default class extends Controller {
  static targets = ["input", "playerTotal", "grandTotal", "submit"]
  static values = {
    expectedTotal: Number
  }

  connect() {
    this.updateTotals()
  }

  updateTotals() {
    // Calculate totals for each player
    const playerTotals = {}
    let grandTotal = 0

    this.inputTargets.forEach(input => {
      const count = parseInt(input.value || 0)
      const value = parseFloat(input.dataset.value)
      const total = count * value
      const playerId = input.name.match(/player_results\[(\d+)\]/)[1]

      playerTotals[playerId] = (playerTotals[playerId] || 0) + total
      grandTotal += total
    })

    // Update player totals
    this.playerTotalTargets.forEach(element => {
      const playerId = element.dataset.playerId
      element.textContent = `$${playerTotals[playerId]?.toFixed(2) || "0.00"}`
    })

    // Update grand total and validate
    this.grandTotalTarget.textContent = `$${grandTotal.toFixed(2)}`
    
    // Enable/disable submit button based on total match
    const isValid = grandTotal === this.expectedTotalValue
    this.submitTarget.disabled = !isValid
    
    // Update visual feedback
    this.grandTotalTarget.classList.toggle("text-red-400", !isValid)
    this.grandTotalTarget.classList.toggle("text-primary-50", isValid)
  }
} 