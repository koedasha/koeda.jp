import "@hotwired/turbo"
import { Application } from "@hotwired/stimulus"
import { hoge } from "/assets/hoge.js" // TMP

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

hoge() // TMP

export { application }
