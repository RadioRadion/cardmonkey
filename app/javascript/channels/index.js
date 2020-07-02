// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

const channels = require.context('.', true, /_channel\.js$/)
channels.keys().forEach(channels)

import {scrollLastMessageIntoView} from "./scroll.js"

scrollLastMessageIntoView();

import {initChatroomCable} from "./chatroom_channel.js"

initChatroomCable();
