import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("fusuma connected")
    console.log("before:", this.element.className)

    this.titleTimeout = setTimeout(() => {
      this.element.classList.add("show-title")
    }, 100)

    this.openTimeout = setTimeout(() => {
      this.element.classList.add("is-open")
    }, 1200)

    this.fadeTimeout = setTimeout(() => {
      this.element.classList.add("hide-title")
    }, 1200)

    this.removeTimeout = setTimeout(() => {
      this.element.remove()
    }, 24000)
      }

  disconnect() {
    clearTimeout(this.titleTimeout)
    clearTimeout(this.openTimeout)
    clearTimeout(this.fadeTimeout)
    clearTimeout(this.removeTimeout)
  }
}
