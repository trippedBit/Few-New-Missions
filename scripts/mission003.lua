source "lua/mission/MissionLib.lua"

NScript.Register(
	{
		Name = "Red rabbit",
		Group = 0,
		Type = MTYPE_BAR,

		Transitions = {
			{nil,
			 nil,
			 "Init",
			 function(V, Data)
				if MissionLib.GetStarSystemId() == 11 then
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_INIT",
			--Replace={"ID_MISSION3_ID"}})
					
					return {Ready=true}
				end
				return {Ready=false}
			 end
			},

			{nil,
			 nil,
			 "Create",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_CREATE",
					--Replace={"ID_MISSION3_ID"}})
				-- MTYPE_BAR only does not create the interface button, therefore an NPC is needed
				if V.NPC == nil then
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_NPC",
			--Replace={"ID_MISSION3_ID"}})
					V.NPCName = NObject.GetName({Race=RACE_RANDOM}).Name
					V.NPC = NNPC.Create({
			Name=V.NPCName,
			Model="Ratsmitglied2",  -- Which models exist?
			Location="02"}).NPC
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_NPC_DONE",
			--Replace={"ID_MISSION3_ID"}})
				end
				V.Reward = 5638
			 end
			},

			{nil,
			 nil,
			 "Subtype",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_SUBTYPE",
					--Replace={"ID_MISSION3_ID"}})
				return {Subtype=SUBTYPE_HEADHUNT}
			 end
			},

			{nil,
			 nil,
			 "MissionStart",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_TARGET",
					--Replace={"ID_MISSION3_ID"}})		
				NStarSystem.SetAsMissionTarget({
					System=MissionLib.GetStarSystemId(),
					Set=true})
				MissionLib.LogUpdateStory()
				V.Step = 1
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_TARGET_DONE",
					--Replace={"ID_MISSION3_ID"}})
			 end
			},

			{1,
			 nil,
			 "Achieved",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_ACHIEVED",
					--Replace={"ID_MISSION3_ID"}})
				V.Step = 0
				return {
					Credits=V.Reward,
					Timeout=-1}
			 end
			},

			{1,
			 nil,
			 "failed",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_FAILED",
					--Replace={"ID_MISSION3_ID"}})
				V.Step = 0
				return {Timeout=-1}
			 end
			},

			{nil,
			 2,
			 "Text",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_TEXTS",
					--Replace={"ID_MISSION3_ID"}})
				return {
					Header="ID_MISSION003_HEADER",
					Client="ID_MISSION003_CLIENT",
					Text="ID_MISSION003_TEXT",
					Credits=V.Reward}
			 end
			},

			{1,
			 1,
			 "Station",
			 function(V, Data)
				if Data.Enter == false then
					-- "Destroy" NPC to remove the interface button
					if V.NPC then
			--NGUI.ShowInfoText({
				--Text="ID_MISSION_NPC_DESTROY",
				--Replace={"ID_MISSION3_ID"}})
			NNPC.Destroy({NPC=V.NPC})
			V.NPC = nil
			--NGUI.ShowInfoText({
				--Text="ID_MISSION_NPC_DESTROY",
				--Replace={"ID_MISSION3_ID"}})
					end
					
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_ENEMY",
			--Replace={"ID_MISSION3_ID"}})
					V.Wing = NWing.Create({
			WingType=WINGTYPE_HUNTER,
			Number=0,
			LevelOffset=-5,
			Names={
				"ID_MISSION003_HEADER",
				"ID_MISSION003_RED_RABBIT_DISCIPLE"},
			Race=RACE_RANDOM,
			PosType=POSDESCR_FIRST_PLANET}).Wing
					NWing.MakeHostile({Wing=V.Wing})
					V.Step = 2
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_ENEMY_DONE",
			--Replace={"ID_MISSION3_ID"}})
				end
			 end
			},

			{2,
			 nil,
			 "Wing",
			 function(V, Data)
				if Data.Wing == V.Wing and Data.Event == WING_DESTROYED then
					--NGUI.ShowInfoText({
			--Text="ID_MISSION3_ENEMY_DESTROYED",
			--Replace={"ID_MISSION3_ID"}})
					V.Step = 3
					MissionLib.LogUpdateTask()
					NMission.SetState({State=MSTATE_ACHIEVED})
				end
			 end
			}
		}
	}
)