class Application < Sinatra::Base

  get '/' do
    "Distributed Key-Value Store\n\rServer: #{$name}"
  end

  get '/values' do
    content_type :json
    $GlobalHash.to_json
  end

  get '/get/:key' do
    resp = $GlobalHash[params[:key]]
    resp = Communicate.fetch_from_replica(params[:key]) if resp.nil?
    resp = Communicate.fetch_from_other_servers(params[:key]) if resp.nil?
    resp = resp.nil? ? "No Value Found Against Key: #{params[:key]}" : resp.to_s
    resp
  end

  post '/add' do
    params = JSON.parse(request.body.read)
    if params.is_a? Hash
      params.each{|k,v| params[k] = v.to_s}
      $GlobalHash.merge!(params)
    end
    Communicate.update_replicas(params, nil, nil, "add")
    "Success"
  end

  post '/set/:key' do
    val = request.body.read
    if val.is_a? String
      $GlobalHash[params[:key]] = val
    end
    Communicate.update_replicas(nil, params[:key], val, "add")
    "Success"
  end

  post '/remove/:key' do
    resp = $GlobalHash.delete(params[:key])
    if resp.nil?
      resp = "No Value Found Against Key: #{params[:key]}"
    else
      Communicate.update_replicas(nil, params[:key], nil, "remove")
      resp = "Success"
    end
    resp
  end

end
