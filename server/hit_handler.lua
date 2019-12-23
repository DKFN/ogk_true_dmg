local hits = { }

local BODY_POSITIONS = {
	"HEAD",
	"CORPSE",
	"FEETS"
}

local OGK_TRUE_DMG_DEBUG = true
local debug_npc

local function debug(message)
	if OGK_TRUE_DMG_DEBUG then
		print("[OGK][GG] True DMG -- "..message)
	end
end

function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
	if hittype == 2 or hittype == 4 then
    	-- First find the player that is in range of the hit
		-- local victim = GetNearestPlayer2D(hitx, hity)
		-- local victimx, victimy, victimz = GetPlayerLocation(victim)
		
		local victim = debug_npc;
		local victimx, victimy, victimz = GetNPCLocation(debug_npc)

		local victim_feet_pos = victimz - 90;

		-- Finding where the hit happend
		local hit_pos
		if hitz > victim_feet_pos + 50 then
			hit_pos = "CORPSE"
		end
		if hitz > victim_feet_pos + 150 then
			hit_pos = "HEAD"
		end

		if not hit_pos then
			hit_pos = "FEETS"
		end
		
		-- We store it here as we are not sure that the player actually took damage with the position of the hit to see if
		-- it is quite matching the position of when the player took the damage
		hits[victim] = {
			position = {hitx, hity, hitz},
			instigator = player,
			position = hit_pos
		}
		debug("Registered hit by "..player.." | VICTIM FEETS "..victim_feet_pos.." | HIT Y: "..hity.." HIT Z: "..hitz)
	end
end
AddEvent("OnPlayerWeaponShot", OnPlayerWeaponShot)

-- For calculus of the damage boost it is simple
-- Head: Apply a boost on the damage (like 0.5)
-- Corpse: Do nothing
-- Feet: Add a bit to player health to counteract real damage
function DamageHandler(player, damagetype, amount)
	if hits[player] then
		local hit = hits[player]
		local hit_pos = hits[player].position
		--local player_health = GetPlayerHealth(player)
		local player_health = GetNPCHealth(player)
		
		debug("Player damage was registered. Caused by "..hit.instigator.." at position"..hit_pos)
		
		-- Defines the health to assign player before hit
		local health_bonus = player_health
		if hit_pos == "HEAD" then
			health_bonus = -(amount * 0.5)
		elseif hit_pos == "FEETS" then
			health_bonus = (amount * 0.3)
		else
			health_bonus = 0
		end

		-- Check that the player still has 1 health at least after setting player health so that it is not the server
		-- registering the kill
		if player_health + health_bonus <= 0 then
			health_bonus = 1
		end

		-- SetPlayerHealth(player, health_bonus)
		SetNPCHealth(debug_npc, player_health + health_bonus)
		
		hits[player] = nil

		AddPlayerChatAll("Bonus to health will be ".. health_bonus .. " bonus from hit")
		
		
	else
		debug("Player "..player.." did not took damage from registred gunshot")
	end
end
AddEvent("OnPlayerDamage", DamageHandler)


if OGK_TRUE_DMG_DEBUG then
	AddEvent("OnNPCDamage", DamageHandler)

	-- Debug function
	AddEvent("OnPackageStart", function()
		debug("Debug mode")
		debug_npc = CreateNPC(42180.0, 201287.0, 551.0, 0)
	end)
end
