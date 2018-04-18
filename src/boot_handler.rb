require 'digest/md5'
require 'multicast'
require 'securerandom'
require 'json'

# administratively scoped multicast addresses are 239.0.0.0 to 239.255.255.255

# Ignoring the cases where there is a collision while hasing the cluster name
# to multicast address. The probability of it is quite low, as MD5 technique
# is being used, and the last three parts of the ip address are generated by
# mapping such a hash to integers less than 235. The original idea was that
# when a collision occurs, we would increase the last part by 1. That is one
# reason why the addresses are generated between 0-235 and not 0-255, because
# whenever a collision occurs between two cluster names to a same number, then
# we can assign it 236, 237.. so on untill 255. The probability of 20 cluster
# names mapping to the same ip is practically 0. So 235 is fairly a same number
# to choose. Also, if any such cases arise, then we can use 236,237.. in the
# third part of the address, then in the second part. So the probability of 60
# clusters mapping to same ip is zero.


# Also, this application does not establish a direct TCP connection between the
# other nodes that are in the same cluster. One reason for this is the lack of
# time for the deadline, also it would require immense amount of time and precision
# in development, which is practically not possible for a two-day assignment. But
# the general idea is to make a mesh topology among the nodes in the same cluster,
# instead of multicast messages. This will make it easier to fetch the results from
# other nodes in the cluster. Here, the communication is asynchronous.

def get_multicast_address
  raise "RESTRICTED CLUSTER NAME" if $cluster_name=="::BROADCAST::"
  md5 = Digest::MD5.hexdigest($cluster_name)
  a = md5.split(/[a-f]/).map{|x| x.to_i if x!=""}.compact
  first, second, third = (a[0]%235), (a[1]%235), (a[2]%235)
  return "239.#{first}.#{second}.#{third}"
end

def make_multicast_connections
  $name = SecureRandom.hex
  $multicast_address = get_multicast_address

  $sender = Multicast::Sender.new(:group => $multicast_address, :port => 4567)
  $listener = Multicast::Listener.new(:group => $multicast_address, :port => 4567)

  $keysender = Multicast::Sender.new(:group => $multicast_address, :port => 4568)
  $keylistener = Multicast::Listener.new(:group => $multicast_address, :port => 4568)

  $clustersender = Multicast::Sender.new(:group => $multicast_address, :port => 4566)
  $clusterlistener = Multicast::Listener.new(:group => $multicast_address, :port => 4566)

  $replicasender = Multicast::Sender.new(:group => $multicast_address, :port => 4569)
  $replicalistener = Multicast::Listener.new(:group => $multicast_address, :port => 4569)
end

def inform_cluster_nodes
  join_cluster_message = {
    "name" => $name,
    "cluster" => $cluster_name
  }
  $clustersender.send(join_cluster_message.to_json)
end

puts "Booting The Application"
make_multicast_connections
inform_cluster_nodes

$replica_handle_thrd = Thread.new do
  $replicalistener.listen do |pl|
    entity = JSON.parse(pl.message)
    if (entity["node_name"]==$broadcast_name || entity["node_name"]==$name) && (entity["host"]!=$name)
      Communicate.handle_replica(entity)
    end
  end
end

$clsuter_message_thrd = Thread.new do
  $clusterlistener.listen do |pl|
    node_details = JSON.parse(pl.message)
    host_ip, host_port = pl.ip, pl.port
    Communicate.handle_node_info(node_details, host_ip, host_port)
  end
end

$thr = Thread.new do
  $listener.listen do |pl|
    query, msg = pl.message.split("::")
    if (query == "GETVAL")
      value = $GlobalHash[msg]
      if value
        found_message = {msg => value}
        $keysender.send("FOUNDVAL::#{found_message.to_json}")
      end
    end
  end
end

