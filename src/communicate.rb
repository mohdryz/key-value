class Communicate
  require 'timeout'

  def self.fetch_from_other_servers(key)
    $sender.send("GETVAL::#{key}")
    ip =  IPAddr.new($keylistener.group).hton + IPAddr.new("0.0.0.0").hton
    sock = UDPSocket.new
    sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
    sock.bind(Socket::INADDR_ANY, $keylistener.port)
    begin
      status = Timeout.timeout(3) { 
        loop do
            begin
              msg, info = sock.recvfrom(1024)
              query, values = msg.split("::")
              if query=="FOUNDVAL"
                puts "Socket Closed"
                pl = JSON.parse(values)
                if pl[key]
                  sock.close
                  return pl[key]
                end
              end
            rescue Interrupt
              sock.close
            end
        end
      }
    rescue Timeout::Error
      sock.close
      return nil
    end
  end
  
end


##.  Communicate.fetch_from_other_servers(key)














