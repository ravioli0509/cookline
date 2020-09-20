require 'line/bot'
require 'dotenv/rails-now'

class WebhookController < ApplicationController
  LIST_WORD = ["作り方", "レシピ", "れしぴ", "つくりかた"]
  GREETINGS = ["おはよう", "こんにちは", "こんばんは", "hello", "hi", "hey"]
  RANDOM_TEXT = ["元気ですか？", "ぽぽぽぽぽぽぽぽ", "一番好きな食べ物は天ぷらだよ、作れる？"]
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
          text_list = event.message["text"].split(/[[:blank:]]+/)
          if (text_list.any? {|word| word.include?(',') || word.include?('、') || word.include?('!')} )
            clean = []
            text_list.each do |i|
              clean << i.split(/\,|\、|!/)
            end
            text_list = clean.flatten
          end 
          greeting  = text_list.filter { |word| word if GREETINGS.include?(word) }[0]
          flag = text_list.any? { |word| LIST_WORD.include?(word) }
          if (greeting)
            message = {
              type: 'text',
              text: greeting+'、'+user+'さん'
            }
            client.reply_message(event['replyToken'], message)
          elsif (flag && text_list.length < 2)
            message = {
              type: 'text',
              text: '「食べ物、レシピ/作り方」って書いてね！'
            }
            client.reply_message(event['replyToken'], message)
          elsif (flag && text_list.length == 2)
              food  = text_list.filter { |word| word if !LIST_WORD.include?(word) }[0]
              # binding.pry
              message = {
                type: 'text',
                text: '検索中。。'
              }
              client.reply_message(event['replyToken'], [message, template(food)])
          else
            message = {
              type: 'text',
              text: RANDOM_TEXT.sample
            }
            client.reply_message(event['replyToken'], message)
          end
        end
      end
    }
    head :ok
  end

  def template(food)
    {
      "type": "template",
      "altText": "メッセージボタン",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://images.unsplash.com/photo-1466637574441-749b8f19452f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1100&q=80",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "レシピサイト",
          "text": "どのレシピサイトから選ぶ？",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "http://example.com/page/123"
          },
          "actions": [
              {
                "type": "uri",
                "label": "味の素",
                "uri": "https://park.ajinomoto.co.jp/recipe/search/?search_word=#{food}"
              },
              {
                "type": "uri",
                "label": "Cookpad",
                "uri": "https://cookpad.com/search/#{food}"
              },
              {
                "type": "uri",
                "label": "Delish Kitchen",
                "uri": "https://delishkitchen.tv/search?q=#{food}"
              }
          ]
      }
    }
  end
end