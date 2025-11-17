class WebhooksController < ApplicationController
  # Webhooks must be accessible without authentication
  skip_before_action :authenticate_user!, only: [:stripe]
  skip_before_action :verify_authenticity_token, only: [:stripe]

  # POST /webhooks/stripe
  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.dig(:stripe, :webhook_secret)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Handle the event
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      handle_successful_payment(payment_intent)
    when 'payment_intent.payment_failed'
      payment_intent = event.data.object
      handle_failed_payment(payment_intent)
    when 'charge.refunded'
      charge = event.data.object
      handle_refund(charge)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    render json: { message: 'success' }, status: 200
  end

  private

  def handle_successful_payment(payment_intent)
    # TODO: Update payment record and booking status
    Rails.logger.info "Payment succeeded: #{payment_intent.id}"
  end

  def handle_failed_payment(payment_intent)
    # TODO: Update payment record with failure
    Rails.logger.info "Payment failed: #{payment_intent.id}"
  end

  def handle_refund(charge)
    # TODO: Process refund
    Rails.logger.info "Charge refunded: #{charge.id}"
  end
end
