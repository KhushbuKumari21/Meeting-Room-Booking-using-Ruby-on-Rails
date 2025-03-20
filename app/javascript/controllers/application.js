import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"
import "controllers"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
import Rails from "@rails/ujs"
Rails.start()
