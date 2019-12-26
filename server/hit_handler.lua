local OGK_TRUE_DMG_DEBUG = false
local debug_npc
local HEADSHOT_BONUS = 35
local CORPSE_BONUS = 10

local function debug(message)
	if OGK_TRUE_DMG_DEBUG then
		print("[OGK][GG] True DMG -- "..message)
	end
end

local function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
	local healthSetter
	local healthGetter
	local positionGetter
	
	if hittype == 2 then
		healthSetter = SetPlayerHealth
		healthGetter = GetPlayerHealth
		positionGetter = GetPlayerLocation
	elseif hittype == 4 then
		healthSetter = SetNPCHealth
		healthGetter = GetNPCHealth
		positionGetter = GetNPCLocation
	end

	if hittype == 2 or hittype == 4 then
    	-- First find the player that is in range of the hit
		local victim = hitid
		local victimx, victimy, victimz = positionGetter(hitid)
	
		local victim_feet_pos = victimz - 90;

		-- Finding where the hit happend and then adding bonus/malus to dmg
		local hit_pos
		local victim_health = healthGetter(hitid)
		local final_health = victim_health

		if hitz > victim_feet_pos + 50 then
			final_health = victim_health - CORPSE_BONUS
		end
		if hitz > victim_feet_pos + 150 then
			CallRemoteEvent(player, "TrueDmgHeadShot")
			final_health = victim_health - HEADSHOT_BONUS
		end
		
		if final_health <= 0 then
			final_health = 1
		end

		healthSetter(victim, final_health)
		debug("Registered hit by "..player.." | VICTIM FEETS "..victim_feet_pos.." | HIT Y: "..hity.." HIT Z: "..hitz)
		debug("Pre-hit damage setting"..final_health)
	end
end
AddEvent("OnPlayerWeaponShot", OnPlayerWeaponShot)

if OGK_TRUE_DMG_DEBUG then
	AddEvent("OnPackageStart", function()
		debug("Debug mode")
		debug_npc = CreateNPC(42180.0, 201287.0, 551.0, 0)
	end)
end
