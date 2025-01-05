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
    this.formats = JSON.parse(document.getElementById('game_formats_data').dataset.formats)
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

    this.updateFormat()
  }

  updateFormat() {
    const formatId = document.getElementById('game_format_id').value
    const format = this.formats.find(f => f.id === parseInt(formatId))
    
    if (!format) return

    // Update expected total
    const expectedTotal = format.buy_in * this.playerCheckboxTargets.filter(cb => cb.checked).length
    this.expectedTotalTarget.textContent = `/ $${expectedTotal.toFixed(2)}`
    
    // Update chip inputs for each selected player
    this.chipInputsTargets.forEach(chipInputs => {
      const playerId = chipInputs.closest('[data-session-form-target="playerCard"]')
                                .querySelector('[data-session-form-target="playerCheckbox"]').value
      
      // Generate chip inputs HTML
      const html = this.generateChipInputsHtml(format, playerId)
      chipInputs.innerHTML = html
    })
    
    this.updateTotals()
  }

  generateChipInputsHtml(format, playerId) {
    const denominations = format.denominations.sort((a, b) => b.value - a.value)
    
    let html = denominations.map(denomination => `
      <div class="flex items-center space-x-3">
        <div class="w-4 h-4 rounded-full border border-primary-600 flex-shrink-0"
             style="background-color: ${this.getColorCode(denomination.color)}"></div>
        
        <div class="flex-grow">
          <div class="flex items-center justify-between">
            <span class="text-sm font-mono text-primary-300">
              $${parseFloat(denomination.value).toFixed(2)}
            </span>
            <input type="number"
                   name="player_results[${playerId}][chip_counts][${denomination.color}]"
                   min="0"
                   step="1"
                   class="w-20 bg-primary-800/50 border-primary-700/50 rounded-lg px-3 py-1 
                          text-right font-mono text-primary-50 focus:border-secondary-400 focus:ring-1 focus:ring-secondary-400
                          [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                   data-session-form-target="chipInput"
                   data-value="${denomination.value}"
                   data-action="input->session-form#updateTotals">
          </div>
        </div>
      </div>
    `).join('')

    // Add player total
    html += `
      <div class="flex items-center justify-between pt-3 border-t border-primary-700/50">
        <span class="font-mono text-primary-300">Total</span>
        <span class="font-mono text-primary-50"
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

  getColorCode(color) {
    const colors = {
      white: '#FFFFFF',
      red: '#EF4444',
      blue: '#3B82F6',
      green: '#10B981',
      black: '#1F2937'
    }
    return colors[color] || '#FFFFFF'
  }
} 