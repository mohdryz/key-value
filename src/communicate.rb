class Communicate
  require 'timeout'
  require 'net/http'
  require "uri"

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

  def self.fetch_from_replica(key)
    $GlobalReplicas.each do |node, hash|
      val = hash[key]
      return val if val
    end
    return nil
  end

  def self.handle_node_info(node_info, host_ip, host_port)
    return if (node_info["cluster"]!=$cluster_name)
    $GlobalHash.each do |key, val|
      sync_replicas_to_new_node(node_info["name"], key, val)
    end
  end

  def self.update_replicas(key_hash, key, value, method)
    key_hash = key_hash || {}
    key_hash.each do |k, v|
      msg = {
        "node_name" => $broadcast_name,
        "value" => v,
        "key" => k,
        "host" => $name
      }
      $replicasender.send(msg.to_json)
    end
    return if key.nil?
    msg = {
      "node_name" => $broadcast_name,
      "host" => $name,
      "key" => key
    }
    msg["value"] = (method=="add") ? value : nil
    $replicasender.send(msg.to_json)
  end

  def self.sync_replicas_to_new_node(node_name, key, val)
    msg = {
      "node_name" => node_name,
      "value" => val,
      "key" => key,
      "host" => $name
    }
    $replicasender.send(msg.to_json)
  end

  def self.handle_replica(msg)
    node = msg["host"]
    $GlobalReplicas[node] = {} if $GlobalReplicas[node].nil?
    $GlobalReplicas[node].merge!({msg["key"] => msg["value"]})
  end
  
end
