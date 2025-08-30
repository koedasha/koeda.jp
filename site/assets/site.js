import "@hotwired/turbo"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "stimulus-loading"

const application = Application.start()
eagerLoadControllersFrom("controllers", application)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Ensure scroll to top on page navigation
document.addEventListener("turbo:load", () => {
  window.scrollTo(0, 0)
})

export { application }
