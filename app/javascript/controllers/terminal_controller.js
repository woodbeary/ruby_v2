import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "restoreButton", "updates", "handle"]
  
  // Class-level variable to store messages across instances but within session
  static messages = []

  connect() {
    this.isMinimized = false
    this.isMaximized = false
    this.isDragging = false
    this.startX = 0
    this.startY = 0
    this.originalHeight = this.contentTarget.offsetHeight
    this.originalWidth = this.element.offsetWidth
    this.autoScroll = true

    // Initialize terminal if no messages exist
    if (this.constructor.messages.length === 0) {
      this.initializeTerminal()
    } else {
      // Restore existing messages from current session
      this.constructor.messages.forEach(msg => this.appendMessage(msg))
    }

    // Bind the drag events
    this.boundDrag = this.drag.bind(this)
    this.boundStopDragging = this.stopDragging.bind(this)

    // Add global event listeners for drag
    document.addEventListener('mousemove', this.boundDrag)
    document.addEventListener('mouseup', this.boundStopDragging)
    document.addEventListener('touchmove', this.boundDrag)
    document.addEventListener('touchend', this.boundStopDragging)

    // Listen for terminal log events
    this.logListener = this.handleLog.bind(this)
    document.addEventListener("terminal:log", this.logListener)

    // Track manual scrolling
    const terminal = document.getElementById("dev-terminal")
    terminal.addEventListener("scroll", () => {
      const { scrollTop, scrollHeight, clientHeight } = terminal
      this.autoScroll = scrollHeight - (scrollTop + clientHeight) < 50
    })

    // Store original position
    this.originalPosition = {
      right: '1rem',
      bottom: '1rem'
    }
  }

  handleLog(event) {
    const message = event.detail.message
    this.constructor.messages.push(message)
    this.appendMessage(message)
  }

  appendMessage(message) {
    const terminalUpdates = document.getElementById("terminal-updates")
    const messageElement = document.createElement("div")
    
    if (typeof message === 'string') {
      messageElement.className = "text-gray-300"
      messageElement.innerHTML = message
    } else {
      messageElement.className = message.class
      messageElement.textContent = message.text
    }
    
    terminalUpdates.appendChild(messageElement)

    // Simple auto-scroll if we're near the bottom
    const terminal = document.getElementById("dev-terminal")
    if (terminal.scrollHeight - terminal.scrollTop - terminal.clientHeight < 100) {
      terminal.scrollTop = terminal.scrollHeight
    }
  }

  initializeTerminal() {
    const initialMessages = [
      { text: "➜ Initializing DAN (Digital Analysis Network)...", class: "text-green-400" },
      { text: "✓ Rails 7 with Hotwire loaded", class: "text-blue-400" },
      { text: "✓ Turbo Frames enabled for real-time updates", class: "text-blue-400" },
      { text: "✓ SQLite database connection established (ActiveRecord ORM)", class: "text-blue-400" },
      { text: "⚡ WebSocket connection established via Action Cable", class: "text-yellow-400" },
      { text: "☁ Connected to JAI (Jacob's AI Pi) at 23.242.121.228:8080", class: "text-purple-400" },
      { text: "   └─ Hardware: Raspberry Pi 5 (8GB RAM)", class: "text-gray-400" },
      { text: "   └─ Brain: Llama 3.2 (1B parameters)", class: "text-gray-400" },
      { text: "   └─ Model: Optimized for edge deployment with 128K context", class: "text-gray-400" },
      { text: "   └─ Features: State-of-the-art for on-device summarization & classification", class: "text-gray-400" },
      { text: "DAN is monitoring JAI and ready for incidents...", class: "text-green-400" }
    ]

    initialMessages.forEach(msg => this.appendMessage(msg))
  }

  disconnect() {
    document.removeEventListener('mousemove', this.boundDrag)
    document.removeEventListener('mouseup', this.boundStopDragging)
    document.removeEventListener('touchmove', this.boundDrag)
    document.removeEventListener('touchend', this.boundStopDragging)
    document.removeEventListener("terminal:log", this.logListener)
  }

  minimize() {
    if (this.isMinimized) {
      this.contentTarget.style.height = `${this.originalHeight}px`
      this.isMinimized = false
    } else {
      this.contentTarget.style.height = "0px"
      this.isMinimized = true
    }
  }

  maximize() {
    if (this.isMaximized) {
      // Restore to original size and position
      this.element.classList.remove("fixed", "inset-0", "m-0", "rounded-none")
      this.element.classList.add("w-96", "rounded-lg")
      this.contentTarget.style.height = `${this.originalHeight}px`
      
      // Reset to the last known position before maximizing
      if (this.lastPosition) {
        this.element.style.left = this.lastPosition.left
        this.element.style.top = this.lastPosition.top
        this.element.style.right = this.lastPosition.right
        this.element.style.bottom = this.lastPosition.bottom
      } else {
        // If no last position, reset to default bottom-right
        this.element.style.left = 'auto'
        this.element.style.top = 'auto'
        this.element.style.right = '1rem'
        this.element.style.bottom = '1rem'
      }
      
      this.isMaximized = false
    } else {
      // Store current position before maximizing
      this.lastPosition = {
        left: this.element.style.left,
        top: this.element.style.top,
        right: this.element.style.right,
        bottom: this.element.style.bottom
      }
      
      // Go fullscreen
      this.element.classList.remove("w-96", "rounded-lg")
      this.element.classList.add("fixed", "inset-0", "m-0", "rounded-none")
      this.contentTarget.style.height = "calc(100vh - 40px)" // Account for header
      
      // Reset all positions for fullscreen
      this.element.style.left = '0'
      this.element.style.top = '0'
      this.element.style.right = '0'
      this.element.style.bottom = '0'
      
      this.isMaximized = true
    }
  }

  close() {
    this.element.classList.add("hidden")
    this.restoreButtonTarget.classList.remove("hidden")
  }

  restore() {
    this.element.classList.remove("hidden")
    this.restoreButtonTarget.classList.add("hidden")
  }

  startDragging(event) {
    if (this.isMaximized) return
    
    this.isDragging = true
    const touch = event.type === 'touchstart' ? event.touches[0] : event

    // Get the current window position
    const rect = this.element.getBoundingClientRect()
    
    // Calculate the offset from the mouse to the window corner
    this.offsetX = touch.clientX - rect.left
    this.offsetY = touch.clientY - rect.top

    // Prevent text selection while dragging
    event.preventDefault()
  }

  drag(event) {
    if (!this.isDragging) return
    
    const touch = event.type === 'touchmove' ? event.touches[0] : event
    
    // Calculate new position
    let newX = touch.clientX - this.offsetX
    let newY = touch.clientY - this.offsetY

    // Get window dimensions
    const windowWidth = window.innerWidth
    const windowHeight = window.innerHeight
    const terminalWidth = this.element.offsetWidth
    const terminalHeight = this.element.offsetHeight

    // Keep terminal within window bounds
    newX = Math.max(0, Math.min(newX, windowWidth - terminalWidth))
    newY = Math.max(0, Math.min(newY, windowHeight - terminalHeight))

    // Update position
    this.element.style.right = 'auto'
    this.element.style.bottom = 'auto'
    this.element.style.left = `${newX}px`
    this.element.style.top = `${newY}px`
  }

  stopDragging() {
    this.isDragging = false
  }
} 