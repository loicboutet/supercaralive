class TestJob < ApplicationJob
  queue_as :default

  def perform(message = "Hello from Solid Queue!")
    Rails.logger.info "TestJob executed: #{message}"
    puts "TestJob executed: #{message}"
  end
end

