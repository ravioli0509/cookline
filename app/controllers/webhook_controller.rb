require 'line/bot'
require 'dotenv/rails-now'

class WebhookController < ApplicationController

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      response_body = JSON.parse(client.get_profile(event["source"]["userId"]).body)
      user = response_body["displayName"]
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: 'Hey '+user+ ', thanks for using the ravioli bot. More updates coming soon'
            }
            client.reply_message(event['replyToken'], message)
        end
      end
    }
    head :ok
  end
end