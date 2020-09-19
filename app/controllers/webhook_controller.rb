require 'line/bot'

class WebhookController < ApplicationController

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = "b5006a0a083952ddb405036effc31ce8"
      config.channel_token = "mcqJjae/lJ3Im6KKW4mQCGwk8uQbb1PuLpcxidpcuW17xNs9ChNCdwrwKxFdDLKWcmWSEY9xj+BUQ1c9abIs93ktrCbs7TFEQauhQi+V30xhA41aJMwHf+v8ja1m/fqjnuYZZFeh0wjhGm4JobAkBQdB04t89/1O/w1cDnyilFU="
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
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: 'STOP CHIBINKO'
            }
            client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end