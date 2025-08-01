import "@hotwired/turbo"
import { Application } from "@hotwired/stimulus"
import RemoteModalController from "controllers/remote_modal_controller.js"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

application.register("remote-modal", RemoteModalController)

export { application }
