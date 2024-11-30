// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

import { createConsumer } from "@rails/actioncable"
window.App || (window.App = {});
window.App.cable = createConsumer();

import "./chatroom_channel"
