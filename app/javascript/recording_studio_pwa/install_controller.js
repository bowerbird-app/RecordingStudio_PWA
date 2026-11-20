import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["install", "installed"]

  connect() {
    this.promptEvent = null
    this.capturePrompt = (event) => {
      event.preventDefault()
      this.promptEvent = event
      this.installTarget.hidden = false
    }
    this.markInstalled = () => this.showInstalled()

    if (this.standalone()) {
      this.showInstalled()
      return
    }

    window.addEventListener("beforeinstallprompt", this.capturePrompt)
    window.addEventListener("appinstalled", this.markInstalled)

    if (this.lacksInstallPrompt()) {
      requestAnimationFrame(() => this.openDevice(this.deviceKey()))
    }
  }

  disconnect() {
    window.removeEventListener("beforeinstallprompt", this.capturePrompt)
    window.removeEventListener("appinstalled", this.markInstalled)
  }

  install() {
    const promptEvent = this.promptEvent
    if (!promptEvent) return

    this.promptEvent = null
    this.installTarget.hidden = true
    promptEvent.prompt()
  }

  showInstalled() {
    this.installTarget.hidden = true
    this.installedTarget.hidden = false
  }

  openDevice(device) {
    const trigger = this.element.querySelector(`[aria-controls="${device}-content"]`)
    if (!trigger || trigger.getAttribute("aria-expanded") === "true") return

    trigger.click()
  }

  standalone() {
    const displayMode = window.matchMedia("(display-mode: standalone)").matches
    return displayMode || window.navigator.standalone === true
  }

  lacksInstallPrompt() {
    if (this.ios()) return true

    const agent = navigator.userAgent || ""
    if (/Firefox/i.test(agent)) return true

    return /Safari/i.test(agent) && !/Chrome|Chromium|Edg|OPR|Android/i.test(agent)
  }

  deviceKey() {
    if (this.ios()) return "iphone"
    if (/Android/i.test(navigator.userAgent || "")) return "android"
    if (/Mac/i.test(navigator.userAgent || "")) return "mac"

    return "pc"
  }

  ios() {
    const agent = navigator.userAgent || ""
    if (/iPad|iPhone|iPod/.test(agent)) return true

    return navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1
  }
}
