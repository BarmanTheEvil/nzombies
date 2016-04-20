if SERVER then
	util.AddNetworkString( "Mapping.SyncSettings" )

	local function receiveMapData(len, ply)
		local tbl = net.ReadTable()
		PrintTable(tbl)

		if tbl.startwep then
			Mapping.Settings.startwep = weapons.Get(tbl.startwep) and tbl.startwep or nz.Config.BaseStartingWeapons[1]
		end
		if tbl.startpoints then
			Mapping.Settings.startpoints = tonumber(tbl.startpoints) and tbl.startpoints or 500
		end
		if tbl.numweps then
			Mapping.Settings.numweps = tonumber(tbl.numweps) and tbl.numweps or 2
		end
		if tbl.eeurl then
			Mapping.Settings.eeurl = tbl.eeurl and tbl.eeurl or nil
		end
		if tbl.script then
			Mapping.Settings.script = tbl.script and tbl.script or nil
		end
		if tbl.scriptinfo then
			Mapping.Settings.scriptinfo = tbl.scriptinfo and tbl.scriptinfo or nil
		end
		if tbl.rboxweps then
			Mapping.Settings.rboxweps = tbl.rboxweps and tbl.rboxweps[1] and tbl.rboxweps or nil
		end
		if tbl.wunderfizzperks then
			Mapping.Settings.wunderfizzperks = tbl.wunderfizzperks and tbl.wunderfizzperks[1] and tbl.wunderfizzperks or nil
		end

		for k,v in pairs(player.GetAll()) do
			Mapping:SendMapData(ply)
		end

		-- Mapping.Settings = tbl
	end
	net.Receive( "Mapping.SyncSettings", receiveMapData )

	function Mapping:SendMapData(ply)
		net.Start("Mapping.SyncSettings")
			net.WriteTable(self.Settings)
		net.Send(ply)
	end
end

if CLIENT then
	local function cleanUpMap()
		game.CleanUpMap()
	end

	net.Receive("nzCleanUp", cleanUpMap )

	local function receiveMapData()
		local oldeeurl = Mapping.Settings.eeurl or ""
		Mapping.Settings = net.ReadTable()

		if !EEAudioChannel or (oldeeurl != Mapping.Settings.eeurl and Mapping.Settings.eeurl) then
			EasterEggData.ParseSong()
		end
		
		-- Precache all random box weapons in the list
		if Mapping.Settings.rboxweps then
			for k,v in pairs(Mapping.Settings.rboxweps) do
				local wep = weapons.Get(v)
				if wep and (wep.WM or wep.WorldModel) then
					util.PrecacheModel(wep.WM or wep.WorldModel)
				end
			end
		end
	end
	net.Receive( "Mapping.SyncSettings", receiveMapData )

	function Mapping:SendMapData( data )
		if data then
			net.Start("Mapping.SyncSettings")
				net.WriteTable(data)
			net.SendToServer()
		end
	end
end
