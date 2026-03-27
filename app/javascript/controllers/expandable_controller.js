import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { expanded: { type: Boolean, default: false } }

  connect() {
    this.render()
  }

  toggle() {
    this.expandedValue = !this.expandedValue
    this.render()
  }

  render() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.toggle("hidden", !this.expandedValue)
    }
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = this.expandedValue ? "rotate(180deg)" : ""
    }
  }
}
