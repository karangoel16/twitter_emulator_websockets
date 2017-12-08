defmodule TwitterNewWeb.RoomChannel.Counter do
        use GenServer

    def start_link(args) do
        GenServer.start_link(__MODULE__,args,name: {:global,:Counter})
    end
    
    #we are maintaining the state of the number 
    def init(args) do
        {:ok,{0,[0]}}
    end

    def handle_call({msg,random},_from,state) do
        reply=""
        case msg do
            :server-> reply=elem(state,0)
            :counter->
                reply=Enum.max(elem(state,1))
        end
        {:reply,reply,state}
    end

    def handle_cast({msg,number},state) do
        case msg do
            :val-> 
                 temp=elem(state,0)+1
                 state=Tuple.delete_at(state,0)|>Tuple.insert_at(0,temp)
            :counter->
                user=elem(state,1)
                user=List.to_tuple(user)|>Tuple.append(elem(state,0)-number)|>Tuple.to_list
                state=Tuple.delete_at(state,1)|>Tuple.insert_at(1,user)
        end
        {:noreply,state}
    end

end