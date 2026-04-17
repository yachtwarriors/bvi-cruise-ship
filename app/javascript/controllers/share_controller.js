import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]
  static values = { url: String }

  async copy() {
    const url = this.urlValue || window.location.href
    try {
      await navigator.clipboard.writeText(url)
    } catch (_e) {
      this.fallbackCopy(url)
    }
    this.showCopied()
  }

  showCopied() {
    if (!this.hasLabelTarget) return
    if (!this._original) this._original = this.labelTarget.textContent
    this.labelTarget.textContent = "Copied!"
    clearTimeout(this._resetTimer)
    this._resetTimer = setTimeout(() => {
      this.labelTarget.textContent = this._original
    }, 2000)
  }

  fallbackCopy(text) {
    const ta = document.createElement("textarea")
    ta.value = text
    ta.style.position = "fixed"
    ta.style.opacity = "0"
    document.body.appendChild(ta)
    ta.select()
    try { document.execCommand("copy") } catch (_e) {}
    document.body.removeChild(ta)
  }
}
