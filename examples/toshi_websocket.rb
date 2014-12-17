require 'faye/websocket'
require 'eventmachine'

Thread.new {

  EM.run {
    ws = Faye::WebSocket::Client.new('ws://localhost:5000')

    ws.on :open do |event|
      p [:open]
      ws.send('{"subscribe":"'+"transactions"+'"}')
    end

    ws.on :message do |event|
      p ("new event [#{event.data}]")
      # do some magic here
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason] if print
      ws = nil
      EM.stop
    end

    Signal.trap("INT")  { p [:INT] ; ws.close }
    Signal.trap("TERM") { p [:TERM]; ws.close }
  }

}
