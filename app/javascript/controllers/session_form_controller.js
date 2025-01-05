import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="session-form"
export default class extends Controller {
  static targets = [
    "playerCard",
    "playerCheckbox",
    "chipInputs",
    "chipInput",
    "playerTotal",
    "grandTotal",
    "expectedTotal",
    "submit"
  ]

  connect() {
    this.updateFormat()
  }

  togglePlayer(event) {
    const card = event.currentTarget
    const checkbox = card.querySelector('[data-session-form-target="playerCheckbox"]')
    const chipInputs = card.querySelector('[data-session-form-target="chipInputs"]')

    // Toggle selection
    checkbox.checked = !checkbox.checked
    card.classList.toggle('border-secondary-400', checkbox.checked)
    chipInputs.classList.toggle('hidden', !checkbox.checked)

    // Clear inputs if unselected
    if (!checkbox.checked) {
      chipInputs.querySelectorAll('input[type="number"]').forEach(input => {
        input.value = ''
      })
    }

    this.updateTotals()
  }

  updateFormat() {
    const formatId = document.getElementById('game_format_id').value
    const format = this.getGameFormat(formatId)
    
    if (!format) return

    const expectedTotal = format.buy_in * this.playerCheckboxTargets.filter(cb => cb.checked).length
    this.expectedTotalTarget.textContent = `/ $${expectedTotal.toFixed(2)}`
    
    this.updateTotals()
  }

  updateTotals() {
    // Calculate totals for each player
    const playerTotals = {}
    let grandTotal = 0

    this.chipInputTargets.forEach(input => {
      if (!input.closest('[data-session-form-target="chipInputs"]').classList.contains('hidden')) {
        const count = parseInt(input.value || 0)
        const value = parseFloat(input.dataset.value)
        const total = count * value
        const playerId = input.name.match(/player_results\[(\d+)\]/)[1]

        playerTotals[playerId] = (playerTotals[playerId] || 0) + total
        grandTotal += total
      }
    })

    // Update player totals
    this.playerTotalTargets.forEach(element => {
      const playerId = element.dataset.playerId
      element.textContent = `$${playerTotals[playerId]?.toFixed(2) || "0.00"}`
    })

    // Update grand total and validate
    this.grandTotalTarget.textContent = `$${grandTotal.toFixed(2)}`
    
    // Enable/disable submit button based on total match
    const formatId = document.getElementById('game_format_id').value
    const format = this.getGameFormat(formatId)
    const expectedTotal = format ? format.buy_in * this.playerCheckboxTargets.filter(cb => cb.checked).length : 0
    
    const isValid = Math.abs(grandTotal - expectedTotal) < 0.01 && this.playerCheckboxTargets.some(cb => cb.checked)
    this.submitTarget.disabled = !isValid
    
    // Update visual feedback
    this.grandTotalTarget.classList.toggle("text-red-400", !isValid)
    this.grandTotalTarget.classList.toggle("text-primary-50", isValid)
  }

  getGameFormat(id) {
    const formats = JSON.parse(document.getElementById('game_formats_data').textContent)
    return formats.find(f => f.id === parseInt(id))
  }
} 