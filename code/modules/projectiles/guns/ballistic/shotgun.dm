/obj/item/gun/ballistic/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	casing_ejector = FALSE
	var/recentpump = 0 // to prevent spammage
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/ballistic/shotgun/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		playsound(user, 'sound/weapons/shotguninsert.ogg', 60, 1)
		A.update_icon()
		update_icon()

/obj/item/gun/ballistic/shotgun/process_chamber(mob/living/user, empty_chamber = 0)
	return ..() //changed argument value

/obj/item/gun/ballistic/shotgun/chamber_round()
	return

/obj/item/gun/ballistic/shotgun/can_shoot()
	if(!chambered)
		return 0
	return (chambered.BB ? 1 : 0)

/obj/item/gun/ballistic/shotgun/attack_self(mob/living/user)
	if(recentpump > world.time)
		return
	if(IS_STAMCRIT(user))//CIT CHANGE - makes pumping shotguns impossible in stamina softcrit
		to_chat(user, "<span class='warning'>You're too exhausted for that.</span>")//CIT CHANGE - ditto
		return//CIT CHANGE - ditto
	pump(user, TRUE)
	if(HAS_TRAIT(user, TRAIT_FAST_PUMP))
		recentpump = world.time + 2
	else
		recentpump = world.time + 10
		if(istype(user))//CIT CHANGE - makes pumping shotguns cost a lil bit of stamina.
			user.adjustStaminaLossBuffered(2) //CIT CHANGE - DITTO. make this scale inversely to the strength stat when stats/skills are added
	return

/obj/item/gun/ballistic/shotgun/blow_up(mob/user)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user, FALSE)
		. = 1

/obj/item/gun/ballistic/shotgun/proc/pump(mob/M, visible = TRUE)
	if(visible)
		M.visible_message("<span class='warning'>[M] racks [src].</span>", "<span class='warning'>You rack [src].</span>")
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/gun/ballistic/shotgun/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.forceMove(drop_location())//Eject casing
		chambered.bounce_away()
		chambered = null

/obj/item/gun/ballistic/shotgun/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/gun/ballistic/shotgun/examine(mob/user)
	. = ..()
	if (chambered)
		. += "A [chambered.BB ? "live" : "spent"] one is in the chamber."

/obj/item/gun/ballistic/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/ballistic/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	fire_delay = 7
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."
	unique_reskin = list("Tactical" = "riotshotgun",
						"Wood Stock" = "wood_riotshotgun"
						)

/obj/item/gun/ballistic/shotgun/riot/attackby(obj/item/A, mob/user, params)
	..()
	if(A.tool_behaviour == TOOL_SAW || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/melee/transforming/energy))
		var/obj/item/melee/transforming/energy/W = A
		if(W.active)
			sawoff(user)

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/ballistic/shotgun/boltaction
	name = "\improper Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago. It feels slightly moist."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = 0 //no ITEM_SLOT_BACK sprite, alas
	inaccuracy_modifier = 0.5
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	var/bolt_open = FALSE
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13

/obj/item/gun/ballistic/shotgun/boltaction/improvised
	name = "Makeshift 7.62mm Rifle"
	icon_state = "ishotgun"
	icon_state = "irifle"
	item_state = "shotgun"
	desc = "A bolt-action breechloaded rifle that takes 7.62mm bullets."
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/improvised
	can_bayonet = FALSE
	var/slung = FALSE

/obj/item/gun/ballistic/shotgun/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	if(bolt_open)
		pump_reload(M)
	else
		pump_unload(M)
	bolt_open = !bolt_open
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/gun/ballistic/shotgun/boltaction/attackby(obj/item/A, mob/user, params)
	if(!bolt_open)
		to_chat(user, "<span class='notice'>The bolt is closed!</span>")
		return
	. = ..()

/obj/item/gun/ballistic/shotgun/boltaction/examine(mob/user)
	. = ..()
	. += "The bolt is [bolt_open ? "open" : "closed"]."

/obj/item/gun/ballistic/shotgun/boltaction/improvised/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_off)
		if(A.use_tool(src, user, 0, 10, skill_gain_mult = EASY_USE_TOOL_MULT))
			slot_flags = ITEM_SLOT_BACK
			to_chat(user, "<span class='notice'>You tie the lengths of cable to the rifle, making a sling.</span>")
			slung = TRUE
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling!</span>")

/obj/item/gun/ballistic/shotgun/boltaction/improvised/update_overlays()
	. = ..()
	if(slung)
		. += "[icon_state]sling"

/obj/item/gun/ballistic/shotgun/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	var/gun_type
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted

/obj/item/gun/ballistic/shotgun/boltaction/enchanted/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	fire_sound = 'sound/weapons/emitter.ogg'
	pin = /obj/item/firing_pin/magic
	icon_state = "arcane_barrage"
	item_state = "arcane_barrage"
	can_bayonet = FALSE
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage

/obj/item/gun/ballistic/shotgun/boltaction/enchanted/Initialize()
	. = ..()
	bolt_open = TRUE
	pump()
	gun_type = type

/obj/item/gun/ballistic/shotgun/boltaction/enchanted/dropped(mob/user)
	..()
	guns_left = 0

/obj/item/gun/ballistic/shotgun/boltaction/enchanted/proc/discard_gun(mob/user)
	throw_at(pick(oview(7,get_turf(user))),1,1)
	user.visible_message("<span class='warning'>[user] tosses aside the spent rifle!</span>")

/obj/item/gun/ballistic/shotgun/boltaction/enchanted/arcane_barrage/discard_gun(mob/user)
	return

/obj/item/gun/ballistic/shotgun/boltaction/enchanted/attack_self()
	return

/obj/item/gun/ballistic/shotgun/boltaction/enchanted/shoot_live_shot(mob/living/user, pointblank = FALSE, mob/pbtarget, message = 1, stam_cost = 0)
	..()
	if(guns_left)
		var/obj/item/gun/ballistic/shotgun/boltaction/enchanted/GUN = new gun_type
		GUN.guns_left = guns_left - 1
		user.dropItemToGround(src, TRUE)
		user.swap_hand()
		user.put_in_hands(GUN)
	else
		user.dropItemToGround(src, TRUE)
	discard_gun(user)

// Automatic Shotguns//

/obj/item/gun/ballistic/shotgun/automatic/shoot_live_shot(mob/living/user, pointblank = FALSE, mob/pbtarget, message = 1, stam_cost = 0)
	..()
	src.pump(user)

/obj/item/gun/ballistic/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	fire_delay = 5
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE
	unique_reskin = list("Tactical" = "cshotgun",
						"Slick" = "cshotgun_slick"
						)

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	name = "warden's combat shotgun"
	desc = "A modified version of the semi automatic combat shotgun with a collapsible stock. For close encounters."
	icon_state = "cshotgunc"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_NORMAL
	var/stock = FALSE
	recoil = 5
	spread = 2

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	toggle_stock(user)
	return TRUE

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to toggle the stock.</span>"

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/proc/toggle_stock(mob/living/user)
	stock = !stock
	if(stock)
		w_class = WEIGHT_CLASS_HUGE
		to_chat(user, "You unfold the stock.")
		recoil = 1
		spread = 0
	else
		w_class = WEIGHT_CLASS_NORMAL
		to_chat(user, "You fold the stock.")
		recoil = 5
		spread = 2
	update_icon()

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/update_icon_state()
	icon_state = "[current_skin ? unique_reskin[current_skin] : "cshotgun"][stock ? "" : "c"]"

//Dual Feed Shotgun

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = FALSE
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to pump it.</span>"

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/Initialize()
	. = ..()
	if (!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		pump()
	else
		toggle_tube(user)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		to_chat(user, "You switch to tube B.")
	else
		to_chat(user, "You switch to tube A.")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	pump()
	return TRUE

// DOUBLE BARRELED SHOTGUN and IMPROVISED SHOTGUN are in revolver.dm

/obj/item/gun/ballistic/shotgun/doublebarrel/hook
	name = "hook modified sawn-off shotgun"
	desc = "Range isn't an issue when you can bring your victim to you."
	icon_state = "hookshotgun"
	item_state = "shotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/bounty
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 16 //it has a hook on it
	attack_verb = list("slashed", "hooked", "stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	//our hook gun!
	var/obj/item/gun/magic/hook/bounty/hook
	var/toggled = FALSE

/obj/item/gun/ballistic/shotgun/automatic/hunting/cowboy
	name = "cowboy repeater"
	desc = "A lever action rifle chambered in .357 Magnum. Smells vaguely of whiskey and cigarettes."
	icon_state = "cowboyrepeater"
	item_state = "cowboyrepeater"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube357
	fire_sound = 'sound/f13weapons/cowboyrepeaterfire.ogg'
//	pump_sound = 'sound/f13weapons/cowboyrepeaterreload.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 4
	can_scope = TRUE


/obj/item/gun/ballistic/shotgun/remington/scoped
	name = "scoped hunting rifle"
	desc = "A sturdy hunting rifle, chambered in 308. and in use before the war. This one has a 8x scope mounted to it."
	icon_state = "rifle308_scope"
	item_state = "scoped308"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/remington
	sawn_desc = "In what is probably the most idiotic and crude modification of a gun you've ever seen, someone has taken this scoped hunting rifle and sawn off the bits that make it well-balanced and accurate."
	fire_sound = 'sound/f13weapons/hunting_rifle.ogg'
	fire_delay = 3
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_scope = FALSE

/obj/item/gun/ballistic/shotgun/hunting
	name = "hunting shotgun"
	desc = "A traditional hunting shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "hunting"
	item_state = "huntingshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	sawn_desc = "A concealed hand blaster, for any situation."

/obj/item/gun/ballistic/shotgun/automatic/hunting/cowboy/scoped
	name = "scoped cowboy repeater"
	desc = "A lever action rifle chambered in .357 Magnum. Smells vaguely of brooding veterans and cigarettes."
	icon_state = "scopedcowboyrepeater"
	item_state = "scopedcowboyrepeater"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube357
	fire_sound = 'sound/f13weapons/cowboyrepeaterfire.ogg'
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 6
	can_scope = FALSE
/obj/item/gun/ballistic/shotgun/automatic/hunting/trail
	name = "trail carbine"
	desc = "A lever action rifle chambered in .44 Magnum."
	icon_state = "trailcarbine"
	item_state = "trailcarbine"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube44
	fire_sound = 'sound/f13weapons/44mag.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 4
	can_scope = TRUE

/obj/item/gun/ballistic/shotgun/automatic/hunting/trail/scoped
	name = "scoped trail carbine"
	desc = "A lever action rifle chambered in .44 Magnum."
	icon_state = "scopedtrailcarbine"
	item_state = "scopedtrailcarbine"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube44
	fire_sound = 'sound/f13weapons/44mag.ogg'
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 6
	can_scope = FALSE

/obj/item/gun/ballistic/shotgun/automatic/hunting/brush
	name = "brush gun"
	desc = "A short lever action rifle chambered in the heavy 45-70 round. Issued to NCR Veteran Rangers in the absence of heavier weaponry."
	icon_state = "brushgun"
	item_state = "brushgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube4570
	fire_sound = 'sound/f13weapons/brushgunfire.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 4
	can_scope = TRUE

/obj/item/gun/ballistic/shotgun/automatic/hunting/brush/scoped
	name = "scoped brush gun (standard)"
	desc = "A short lever action rifle chambered in the heavy 45-70 round. Issued to NCR Veteran Rangers in the absence of heavier weaponry."
	icon_state = "scopedbrushgun"
	item_state = "scopedbrushgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube4570
	fire_sound = 'sound/f13weapons/brushgunfire.ogg'
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 6
	can_scope = FALSE
	extra_penetration = -5
	extra_damage = -5

//Anti-Materiel Rifle (NCR)
/obj/item/gun/ballistic/shotgun/antimateriel
	name = "anti-materiel rifle"
	desc = "A heavy, high-powered sniper rifle chambered in .50 caliber ammunition, custom-made for use by the New California Republic Rangers. Although relatively austere, you're still pretty sure it could take the head off a deathclaw."
	icon_state = "sniper-mag"
	item_state = "sniper"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/antimateriel
	fire_sound = 'sound/f13weapons/antimaterielfire.ogg'
//	pump_sound = 'sound/f13weapons/antimaterielreload.ogg'
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	force = 25
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	recoil = 1 //have fun
	fire_delay = 6
//	projectile_speed = 0 //basically hitscan

//Fallout 13

// Trenchgun //
/obj/item/gun/ballistic/shotgun/trench
	name = "lever action shotgun"
	desc = "A lever action hunting shotgun with a five-shell capacity underneath plus one in chamber."
	icon_state = "trenchgun"
	item_state = "trenchgun"
	can_scope = TRUE
	scopestate = "AEP7_scope"
	scope_x_offset = 8
	scope_y_offset = 19
	can_bayonet = TRUE
//	bayonetstate = "trenchgun"
	knife_x_offset = 23
	knife_y_offset = 14
	mag_type = /obj/item/ammo_box/magazine/internal/shot/trench
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT

//Double Barrel Caravan Shotgun
/obj/item/gun/ballistic/revolver/caravan_shotgun
	name = "caravan shotgun"
	desc = "An common over-under double barreled shotgun."
	icon_state = "caravan_shotgun"
	item_state = "dshotgun1"
	force = 20
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	sawn_desc = "Omar's coming!"
	fire_sound = 'sound/f13weapons/caravan_shotgun.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 1
	distro = 1

/obj/item/gun/ballistic/revolver/caravan_shotgun/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/melee/transforming/energy))
		var/obj/item/melee/transforming/energy/W = A
		if(W.active)
			sawoff(user)
