import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="session-form"
export default class extends Controller {
  static targets = [
    "playerCard",
    "playerCheckbox",
    "playerHeader",
    "expandButton",
    "chipInputs",
    "chipInput",
    "playerTotal",
    "grandTotal",
    "expectedTotal",
    "submit"
  ]

  connect() {
    this.formats = JSON.parse(document.getElementById('game_formats_data').dataset.formats)
    this.updateFormat()
  }

  // Prevent checkbox clicks from triggering header click
  stopPropagation(event) {
    event.stopPropagation()
  }

  handleHeaderClick(event) {
    const header = event.currentTarget
    const card = header.closest('[data-session-form-target="playerCard"]')
    const checkbox = card.querySelector('[data-session-form-target="playerCheckbox"]')
    
    // Only handle click if player is selected
    if (checkbox.checked) {
      this.toggleExpand(card)
    }
  }

  togglePlayer(event) {
    const checkbox = event.target
    const card = checkbox.closest('[data-session-form-target="playerCard"]')
    const expandButton = card.querySelector('[data-session-form-target="expandButton"]')
    const chipInputs = card.querySelector('[data-session-form-target="chipInputs"]')
    const header = card.querySelector('[data-session-form-target="playerHeader"]')

    // Toggle selection visual state
    card.classList.toggle('border-secondary-400', checkbox.checked)
    
    // Show/hide expand button
    expandButton.classList.toggle('hidden', !checkbox.checked)
    
    // Update cursor style
    header.classList.toggle('cursor-pointer', checkbox.checked)
    
    // If unchecking, collapse and clear inputs
    if (!checkbox.checked) {
      chipInputs.classList.add('hidden')
      chipInputs.querySelectorAll('input[type="number"]').forEach(input => {
        input.value = ''
      })
      // Reset arrow rotation
      expandButton.querySelector('svg').style.transform = ''
    }

    this.updateFormat()
  }

  toggleExpand(card) {
    const chipInputs = card.querySelector('[data-session-form-target="chipInputs"]')
    const expandButton = card.querySelector('[data-session-form-target="expandButton"]')
    
    // Toggle expand/collapse
    const isExpanded = !chipInputs.classList.contains('hidden')
    chipInputs.classList.toggle('hidden')
    
    // Rotate arrow icon
    expandButton.querySelector('svg').style.transform = isExpanded ? '' : 'rotate(90deg)'
  }

  updateFormat() {
    const formatId = document.getElementById('game_format_id').value
    const format = this.formats.find(f => f.id === parseInt(formatId))
    
    if (!format) return

    // Update expected total
    const expectedTotal = format.buy_in * this.playerCheckboxTargets.filter(cb => cb.checked).length
    this.expectedTotalTarget.textContent = `(Expected: $${expectedTotal.toFixed(2)})`
    
    // Update chip inputs for each selected player
    this.chipInputsTargets.forEach(chipInputs => {
      const playerId = chipInputs.closest('[data-session-form-target="playerCard"]')
                                .querySelector('[data-session-form-target="playerCheckbox"]').value
      
      // Generate chip inputs HTML
      const html = this.generateChipInputsHtml(format, playerId)
      chipInputs.querySelector('div').innerHTML = html
    })
    
    this.updateTotals()
  }

  generateChipInputsHtml(format, playerId) {
    const denominations = format.denominations.sort((a, b) => b.value - a.value)
    
    let html = denominations.map(denomination => `
      <div class="flex items-center space-x-3">
        <div class="w-24">
          <div class="flex items-center space-x-2">
            <span class="w-4 h-4 rounded-full" style="background-color: ${denomination.color}"></span>
            <span class="font-mono text-primary-400">$${denomination.value}</span>
          </div>
        </div>
        <input type="number"
               name="player_results[${playerId}][chip_counts][${denomination.color}]"
               min="0"
               step="1"
               class="w-24 bg-primary-800/50 border-primary-700/50 rounded-lg px-3 py-2 
                      font-mono text-primary-50 focus:border-secondary-400 focus:ring-1 focus:ring-secondary-400"
               data-session-form-target="chipInput"
               data-value="${denomination.value}"
               data-action="input->session-form#updateTotals">
      </div>
    `).join('')

    // Add player total
    html += `
      <div class="mt-4 pt-4 border-t border-primary-700/50">
        <span class="font-mono text-primary-400">Total:</span>
        <span class="ml-2 font-mono text-primary-50"
              data-session-form-target="playerTotal"
              data-player-id="${playerId}">
          $0.00
        </span>
      </div>
    `

    return html
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
    const format = this.formats.find(f => f.id === parseInt(formatId))
    const expectedTotal = format ? format.buy_in * this.playerCheckboxTargets.filter(cb => cb.checked).length : 0
    
    const isValid = Math.abs(grandTotal - expectedTotal) < 0.01 && this.playerCheckboxTargets.some(cb => cb.checked)
    this.submitTarget.disabled = !isValid
    
    // Update visual feedback
    this.grandTotalTarget.classList.toggle("text-red-400", !isValid)
    this.grandTotalTarget.classList.toggle("text-primary-50", isValid)
  }
} 