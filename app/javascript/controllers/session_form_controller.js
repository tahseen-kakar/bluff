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
    "playerTotalChip",
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
    const totalChip = card.querySelector('[data-session-form-target="playerTotalChip"]')

    // Toggle selection visual state
    if (checkbox.checked) {
      card.classList.remove('border-dashed', 'border-primary-700/30')
      card.classList.add('border-secondary-400/70')
      header.classList.add('cursor-pointer')
      totalChip.classList.remove('hidden')
      totalChip.classList.add('flex')
    } else {
      card.classList.remove('border-secondary-400/70')
      card.classList.add('border-dashed', 'border-primary-700/30')
      header.classList.remove('cursor-pointer')
      totalChip.classList.remove('flex')
      totalChip.classList.add('hidden')
    }
    
    // Show/hide expand button
    expandButton.classList.toggle('hidden', !checkbox.checked)
    
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
    
    return `
      <div class="flex items-center space-x-4">
        ${denominations.map(denomination => `
          <div class="relative">
            <div class="absolute inset-y-0 left-0 flex items-center pl-2 pointer-events-none">
              <span class="w-3 h-3 rounded-full" style="background-color: ${denomination.color}"></span>
              <span class="font-mono text-primary-400 text-sm ml-2">$${denomination.value}</span>
            </div>
            <input type="number"
                   name="player_results[${playerId}][chip_counts][${denomination.color}]"
                   min="0"
                   step="1"
                   placeholder="×0"
                   class="w-32 bg-primary-800/50 border-primary-700/50 rounded-lg pl-16 pr-2 py-1.5
                          font-mono text-primary-50 text-right placeholder:text-primary-700/30
                          focus:border-secondary-400 focus:ring-1 focus:ring-secondary-400"
                   data-session-form-target="chipInput"
                   data-value="${denomination.value}"
                   data-action="input->session-form#updateTotals">
          </div>
        `).join('')}
      </div>
    `
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
      element.textContent = playerTotals[playerId]?.toFixed(2) || "0.00"
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