import "@hotwired/turbo"
import { Application } from "@hotwired/stimulus"
// import RemoteModalController from "controllers/remote_modal_controller.js"
import { eagerLoadControllersFrom } from "stimulus-loading"

const application = Application.start()
eagerLoadControllersFrom("controllers", application)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
