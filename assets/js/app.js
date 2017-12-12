// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import {Socket} from "phoenix";
let user = document.getElementById("user").innerText
let socket = new Socket("/socket",{params:{user : parseInt(user)}})
socket.connect( {user : parseInt(user)});

let room = socket.channel("room:lobby")
room.join(parseInt(user))

let messageInput = document.getElementById("newMessage")
messageInput.addEventListener("keypress",(e)=>{
    if(e.keyCode==13 && messageInput.value !="")
    {
        room.push("shout",{message: messageInput.value})
        messageInput.value=""
    }
})

let messageList = document.getElementById("messageList")
let renderMessage = (message) =>{
    console.log(message)
    console.log(message)
    let messageElement = document.createElement("li")
    messageElement.innerHTML=`
        <b>${message.user}</b><br>
        <i>${message.message}</i>
    `
    messageList.appendChild(messageElement)
    messageList.scrollTop = messageList.scrollHeight;
}
room.on("shout",message => renderMessage(message))