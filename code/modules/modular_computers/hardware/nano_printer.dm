/obj/item/computer_hardware/nano_printer
	name = "nano printer"
	desc = "Small integrated printer with paper recycling module."
	power_usage = 50
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	critical = 0
	icon_state = "printer"
	hardware_size = 1
	var/stored_paper = 5
	var/max_paper = 10

/obj/item/computer_hardware/nano_printer/diagnostics(var/mob/user)
	..()
	to_chat(user, "Paper buffer level: [stored_paper]/[max_paper]")

/obj/item/computer_hardware/nano_printer/proc/print_text(var/text_to_print, var/paper_title = null)
	if(!stored_paper)
		return 0
	if(!enabled)
		return 0
	if(!check_functionality())
		return 0

	var/obj/item/paper/P = new/obj/item/paper(get_turf(holder2))

	// Damaged printer causes the resulting paper to be somewhat harder to read.
	if(damage > damage_malfunction)
		P.info = stars(text_to_print, 100-malfunction_probability)
	else
		P.info = text_to_print
	if(paper_title)
		P.name = paper_title
	P.update_icon()
	P.fields = count_fields(P.info)
	P.updateinfolinks()

	stored_paper--
	return 1

/obj/item/computer_hardware/nano_printer/proc/count_fields(var/info)
//Count the fields. This is taken directly from paper.dm, /obj/item/paper/proc/parsepencode(). -Hawk_v3
	var/fields = 0
	var/t = info
	var/laststart = 1
	while(1)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)	//</span>
		if(i==0)
			break
		laststart = i+1
		fields++
	return fields

/obj/item/computer_hardware/nano_printer/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/paper))
		if(stored_paper >= max_paper)
			to_chat(user, "You try to add \the [W] into \the [src], but its paper bin is full.")
			return

		to_chat(user, "You insert \the [W] into [src].")
		qdel(W)
		stored_paper++
	else if(istype(W, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/B = W
		var/num_of_pages_added = 0
		if(stored_paper >= max_paper)
			to_chat(user, "You try to add \the [W] into \the [src], but its paper bin is full.")
			return
		for(var/obj/item/bundleitem in B) //loop through items in bundle
			if(istype(bundleitem, /obj/item/paper)) //if item is paper (and not photo), add into the bin
				B.pages.Remove(bundleitem)
				qdel(bundleitem)
				num_of_pages_added++
				stored_paper++
			if(stored_paper >= max_paper) //check if the printer is full yet
				to_chat(user, "The printer has been filled to full capacity.")
				break
		if(B.pages.len == 0) //if all its papers have been put into the printer, delete bundle
			qdel(W)
		else if(B.pages.len == 1) //if only one item left, extract item and delete the one-item bundle
			user.drop_from_inventory(B)
			user.put_in_hands(B.pages[1])
			qdel(B)
		else //if at least two items remain, just update the bundle icon
			B.update_icon()
		to_chat(user, "You add [num_of_pages_added] papers from \the [W] into \the [src].")
	return

/obj/item/computer_hardware/nano_printer/Destroy()
	if(holder2 && (holder2.nano_printer == src))
		holder2.nano_printer = null
	holder2 = null
	return ..()
