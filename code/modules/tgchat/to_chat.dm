/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Circumvents the message queue and sends the message
 * to the recipient (target) as soon as possible.
 */
/proc/to_chat_immediate(
	target,
	html,
	type = null,
	text = null,
	avoid_highlighting = FALSE,
	// FIXME: These flags are now pointless and have no effect
	handle_whitespace = TRUE,
	trailing_newline = TRUE,
	confidential = FALSE
)
	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	if(!target)
		return
	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")
	if(target == world)
		target = GLOB.clients

	if(islist(target) && !LAZYLEN(target))
		return

	// Build a message
	var/message = list()
	if(type) message["type"] = type
	if(text) message["text"] = text
	if(html) message["html"] = html
	if(avoid_highlighting) message["avoidHighlighting"] = avoid_highlighting

	// send it immediately
	SSchat.send_immediate(target, message)

	if (CONFIG_GET(flag/chatlog_database_backend))
		if (islist(target))
			for(var/tgt in target)
				var/our_ckey = CKEY_FROM_VAR(tgt)
				if(isnull(our_ckey))
					continue
				vchatlog_write(our_ckey, html, GLOB.round_id, type)
		else
			var/our_ckey = CKEY_FROM_VAR(target)
			if(!isnull(our_ckey))
				vchatlog_write(our_ckey, html, GLOB.round_id, type)

/**
 * Sends the message to the recipient (target).
 *
 * Recommended way to write to_chat calls:
 * ```
 * to_chat(client,
 *     type = MESSAGE_TYPE_INFO,
 *     html = "You have found <strong>[object]</strong>")
 * ```
 */
/proc/to_chat(
	target,
	html,
	type = null,
	text = null,
	avoid_highlighting = FALSE,
	// FIXME: These flags are now pointless and have no effect
	handle_whitespace = TRUE,
	trailing_newline = TRUE,
	confidential = FALSE
)
	//if(isnull(Master) || !SSchat?.initialized || !MC_RUNNING(SSchat.init_stage))
	if(isnull(Master) || !SSchat?.subsystem_initialized)
		to_chat_immediate(target, html, type, text, avoid_highlighting)
		return

	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	if(!target)
		return
	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")
	if(target == world)
		target = GLOB.clients

	if(islist(target) && !LAZYLEN(target))
		return

	// Build a message
	var/message = list()
	if(type) message["type"] = type
	if(text) message["text"] = text
	if(html) message["html"] = html
	if(avoid_highlighting) message["avoidHighlighting"] = avoid_highlighting
	SSchat.queue(target, message)

	if (CONFIG_GET(flag/chatlog_database_backend))
		if (islist(target))
			for(var/tgt in target)
				var/our_ckey = CKEY_FROM_VAR(tgt)
				if(isnull(our_ckey))
					continue
				vchatlog_write(our_ckey, html, GLOB.round_id, type)
		else
			var/our_ckey = CKEY_FROM_VAR(target)
			if(!isnull(our_ckey))
				vchatlog_write(our_ckey, html, GLOB.round_id, type)
