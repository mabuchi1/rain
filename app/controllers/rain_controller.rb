class RainController < ApplicationController
    require 'line/bot'
    require 'net/http'
    require 'uri'
    require 'rexml/document'

    uri = URI.parse('https://www.drk7.jp/weather/xml/27.xml')
    xml = Net::HTTP.get(uri)
    doc = REXML::Document.new(xml)

    xpath = 'weatherforecast/pref/area[0]'
    weather = doc.elements[xpath + '/info/weather'].text
    max = doc.elements[xpath + '/info/temperature/range[1]'].text
    min = doc.elements[xpath + '/info/temperature/range[2]'].text
    per00to06 = doc.elements[xpath + '/info/rainfallchance/period[1]'].text
    per06to12 = doc.elements[xpath + '/info/rainfallchance/period[2]'].text
    per12to18 = doc.elements[xpath + '/info/rainfallchance/period[3]'].text
    per18to24 = doc.elements[xpath + '/info/rainfallchance/period[4]'].text
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
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: event.message['text']
            }
            client.reply_message(event['replyToken'], message)
          end
        end
      }
  
      head :ok
    end
  end