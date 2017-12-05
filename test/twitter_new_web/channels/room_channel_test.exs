defmodule TwitterNewWeb.RoomChannelTest do
  use TwitterNewWeb.ChannelCase
  alias TwitterNewWeb.RoomChannel

  @s 1.3

  def cal_const(number_of_nodes) do
    sum=Enum.sum(Enum.map(1..number_of_nodes,fn(x)->:math.pow(1/x,@s) end))
    #IO.puts sum
    1/sum
  end
  
  setup do
    map=%{}
    map=Enum.reduce(1..1000,map,fn(x,map)->        
        {:ok,_,socket}=socket(x, %{user: x})
        |> subscribe_and_join(RoomChannel, "room:lobby")
        map=Map.put(map,x,socket)
        GenServer.cast({:global,x|>Integer.to_string|>String.to_atom},{:socket,socket,"",""})
        map
    end)
    
    const_no=cal_const(1000)
    const=const_no*1000
    
    IO.puts "Building Subscription list"
    #we have added start to make the messages go on other nodes as well
    Enum.map(1..1000,fn(x)->
      val=Enum.take_random(1..1000,(const/:math.pow(x,@s)|>:math.ceil|>round))
      GenServer.cast({:global,x|>Integer.to_string|>String.to_atom},{:subscribe,val,"",""})
      GenServer.cast({:global,:Server},{:subscribe,x,val,0})

    end)
    {:ok, map: map}
  end

  test "multiple",%{map: map} do
    number_of_tweets="1000"
    number_of_node="1000"
    IO.puts "Starting Tweet"
    #sub=elem(GenServer.call({:Server,Node.self()},{:server,""}),2)
    const_no=cal_const(String.to_integer(number_of_tweets))
    const=const_no*String.to_integer(number_of_tweets)
    spawn(fn->loop(-1) end)
    
    Enum.reduce(1..String.to_integer(number_of_node),0,fn(x,tweet)->
      Enum.reduce(1..(const/:math.pow(x,@s)|>:math.ceil|>round),tweet,fn(y,tweet)->
        #tweet=Map.keys(elem(GenServer.call({:Server,Node.self()},{:server,""},:infinity),0))|>length
        new_tweet=tweet+1
        if GenServer.whereis({:global,x|>Integer.to_string|>String.to_atom})!= nil do
          GenServer.cast({:global,x|>Integer.to_string|>String.to_atom},{:tweet,tweet,"#"<>RandomBytes.base62<>" "<>"@"<>Integer.to_string(:rand.uniform(String.to_integer(number_of_node))),x})
          Process.sleep(10)
        end
        new_tweet
      end)
    end)
    ref=push Map.get(map,1), "ping", %{"msg" => "there"}
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
    #IO.puts prev_len
    len=elem(GenServer.call({:global,:Server},{:server,""}),5)
    IO.puts len-prev_len
    #if prev_len == len do
    #  Process.exit(self(),:kill)
    #end
    Process.sleep(1000)
    loop(len)
  end
end
