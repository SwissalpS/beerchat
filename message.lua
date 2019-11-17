-- Message string formats -- Change these if you would like different formatting
--
-- These can be changed to show "~~~#mychannel~~~ <player01> message" instead of "|#mychannel| or any
-- other format you like such as removing the channel name from the main channel, putting channel or
-- player names at the end of the chat message, etc.
--
-- The following parameters are available and can be specified :
-- ${channel_name} name of the channel
-- ${channel_owner} owner of the channel
-- ${channel_password} password to use when joining the channel, used e.g. for invites
-- ${from_player} the player that is sending the message
-- ${to_player} player to which the message is sent, will contain multiple player names
-- e.g. when sending a PM to multiple players
-- ${message} the actual message that is to be sent
-- ${time} the current time in 24 hour format, as returned from os.date("%X")
--

beerchat.send_on_channel = function(name, channel_name, message)
	for _,player in ipairs(minetest.get_connected_players()) do
		local target = player:get_player_name()
		-- Checking if the target is in this channel
		if beerchat.is_player_subscribed_to_channel(target, channel_name) then
			if not beerchat.has_player_muted_player(target, name) then
				beerchat.send_message(
					target,
					beerchat.format_message(
						beerchat.main_channel_message_string, {
							channel_name = channel_name,
							to_player = target,
							from_player = name,
							message = message
						}
					),
					channel_name
				)
			end
		end
	end
end


minetest.register_on_chat_message(function(name, message)
	local channel_name = beerchat.currentPlayerChannel[name]

	if not beerchat.channels[channel_name] then
		minetest.chat_send_player(
			name,
			"Channel "..channel_name.." does not exist, switching back to "..
				beerchat.main_channel_name..". Please resend your message"
		)
		beerchat.currentPlayerChannel[name] = beerchat.main_channel_name
		minetest.get_player_by_name(name):get_meta():set_string(
			"beerchat:current_channel", beerchat.main_channel_name)
		return true
	end

	if not beerchat.channels[channel_name] then
		minetest.chat_send_player(name, "Channel "..channel_name.." does not exist")
	elseif message == "" then
		minetest.chat_send_player(name,
			"Please enter the message you would like to send to the channel")
	elseif not beerchat.is_player_subscribed_to_channel(name, channel_name) then
		minetest.chat_send_player(name,
			"You need to join this channel in order to be able to send messages to it")
	else
		beerchat.on_channel_message(channel_name, name, message)
		beerchat.send_on_channel(name, channel_name, message)
	end
	return true
end)

