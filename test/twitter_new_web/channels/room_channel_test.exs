defmodule TwitterNewWeb.RoomChannelTest do
  use TwitterNewWeb.ChannelCase
  alias TwitterNewWeb.RoomChannel

  @s 1.3
  @num 1000
  def cal_const(number_of_nodes) do
    sum=Enum.sum(Enum.map(1..number_of_nodes,fn(x)->:math.pow(1/x,@s) end))
    #IO.puts sum
    1/sum
  end
  
  setup do
    #Registering the nodes to the network
    map=%{}
    map=Enum.reduce(1..@num,map,fn(x,map)->        
        {:ok,_,socket}=socket(x, %{user: x})
        |> subscribe_and_join(RoomChannel, "room:lobby")
        map=Map.put(map,x,socket)
        GenServer.cast({:global,x|>Integer.to_string|>String.to_atom},{:socket,socket,"",""})
        map
    end)
    
    const_no=cal_const(@num)
    const=const_no*@num
    
    IO.puts "Building Subscription list"
    #we have added start to make the messages go on other nodes as well
    Enum.map(1..@num,fn(x)->
      val=Enum.take_random(1..@num,(const/:math.pow(x,@s)|>:math.ceil|>round))
      push Map.get(map,x), "subscribe", val 
    end)
    {:ok, map: map}
  end

  test "multiple",%{map: map} do
    number_of_tweets=@num|>Integer.to_string
    number_of_node=@num|>Integer.to_string
    IO.puts "Starting Tweet"
    #sub=elem(GenServer.call({:Server,Node.self()},{:server,""}),2)
    const_no=cal_const(String.to_integer(number_of_tweets))
    const=const_no*String.to_integer(number_of_tweets)
    spawn(fn->loop(-1) end)
    
    IO.inspect Enum.reduce(1..String.to_integer(number_of_node),0,fn(x,tweet)->
      Enum.reduce(1..(const/:math.pow(x,@s)|>:math.ceil|>round),tweet,fn(y,tweet)->
        #tweet=Map.keys(elem(GenServer.call({:Server,Node.self()},{:server,""},:infinity),0))|>length
        new_tweet=tweet+1
        if GenServer.whereis({:global,x|>Integer.to_string|>String.to_atom})!= nil do
          #GenServer.cast({:global,x|>Integer.to_string|>String.to_atom},{:tweet,tweet,"#"<>RandomBytes.base62<>" "<>"@"<>Integer.to_string(:rand.uniform(String.to_integer(number_of_node))),x})
          push Map.get(map,x), "server", {:tweet,tweet,"#"<>RandomBytes.base62<>" "<>"@"<>Integer.to_string(:rand.uniform(String.to_integer(number_of_node))),x}
          Process.sleep(10)
        end
        new_tweet
      end)
    end)
    ref=push Map.get(map,1), "ping", %{"msg" => "there"}
    IO.inspect {"Throughput",GenServer.call({:global,:Counter},{:counter,0})} 
    assert_reply ref, :ok, _
  end

  def random_start_stop(x) do
    Process.sleep(1000)
    if(:rand.uniform(100000)==2) do
      if (GenServer.whereis({:global,x|>Integer.to_string|>String.to_atom})!=nil) do
        GenServer.stop({:global,x|>Integer.to_string|>String.to_atom})
        random_start_stop(x)
      else 
        Project4.Client.start_link(Integer.to_string(x)|>String.to_atom)
        random_start_stop(x)
      end
    else
      random_start_stop(x)
    end
  end


  def loop(prev_len) do
    len=GenServer.call({:global,:Counter},{:server,""},:infinity)
    GenServer.cast({:global,:Counter},{:counter,prev_len})
    #IO.inspect len - prev_len
    Process.sleep(1000)
    loop(len)
  end
end
