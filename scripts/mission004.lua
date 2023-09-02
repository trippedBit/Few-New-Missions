source "lua/mission/MissionLib.lua"

NScript.Register(
	{
		Name = "Save the tourists",
		Group = 0,
		Type = MTYPE_TERMINAL,

		Transitions = {
			{nil,
			 nil,
			 "Init",
			 function(V, Data)
				if MissionLib.GetStarSystemId() == 4 then
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_INIT",
			--Replace={"ID_MISSION4_ID"}})
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
					--Replace={"ID_MISSION4_ID"}})
				V.Reward=NPlayer.StandardReward({Factor=1.5}).Credits
			end
			},

			{nil,
			 nil,
			 "Subtype",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_SUBTYPE",
					--Replace={"ID_MISSION4_ID"}})
				return {Subtype=SUBTYPE_PROTECT}
			end
			},

			{nil,
			 nil,
			 "MissionStart",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_TARGET",
					--Replace={"ID_MISSION4_ID"}})
				NStarSystem.SetAsMissionTarget({
					System=MissionLib.GetStarSystemId(),
					Set=true})
				MissionLib.LogUpdateStory()
				V.Step=1
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_TARGET_DONE",
					--Replace={"ID_MISSION4_ID"}})
			end
			},

			{1,
			 nil,
			 "Achieved",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_ACHIEVED",
					--Replace={"ID_MISSION4_ID"}})
				V.Step=0
				return {
					Credits=V.Reward,
					Timeout=-1}
			end
			},

			{1,
			 nil,
			 "Failed",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_FAILED",
					--Replace={"ID_MISSION4_ID"}})
				
				V.Step=0
				return {Timeout=0}
			end
			},

			{nil,
			 2,
			 "Text",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_TEXTS",
					--Replace={"ID_MISSION4_ID"}})
				return {
					Header="ID_MISSION004_HEADER",
			                    		Client="ID_MISSION004_CLIENT",
			                    		Text="ID_MISSION004_TEXT",
			                    		Credits=V.Reward}
			end
			},

			{1,
			 1,
			 "Station",
			 function(V, Data)
				if Data.Enter == false then
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_WINGS",
			--Replace={"ID_MISSION4_ID"}})
					-- Create Tourist cruiser
					-- WINGTYPE_CRUISER1 and WINGTYPE_CRUISER2 are not working here!
					V.Wing1=NWing.Create({
			WingType=WINGTYPE_FREIGHTER600CAP,
			Number=0,
			LevelOffset=0,
			Names={"ID_MISSION4_WING1"},
			Race=RACE_RANDOM,
			PosType=POSDESCR_INTERCEPTION}).Wing
					-- Create Mercenaries
					-- WINGTYPE_RAIDERS is not working here!
					V.Wing2=NWing.Create({
			WingType=WINGTYPE_HUNTER,
			Number=4,
			PosType=POSDESCR_WINGDISTANCE,
			Object=V.Wing1,
			Distance=1200.0}).Wing
			
					-- Set both Wings to AI_ACTION_WARTEN until Player reaches a specific distance
					NWing.AddAction({
			Wing=V.Wing1,
			List=LIST_ACTIVE,
			First=1,
			Actions={
				{Type=AI_ACTION_WARTEN}}})
					NWing.AddAction({
			Wing=V.Wing2,
			List=LIST_ACTIVE,
			First=1,
			Actions={
				{Type=AI_ACTION_WARTEN}}})
			
					-- Create a waypoint
					ship = MissionLib.GetWingMember(V.Wing1, 0)
					V.WP1 = NWaypoint.Create({
			Object=ship,
			Radius=1500}).Waypoint
					
					-- Mark wing 1 as mission object
					NObject.SetMissionFlag({
			Object=V.Wing1,
			Set=1})
					NPlayer.SelectTarget({Object=ship})
					
					--NGUI.ShowInfoText({
			--Text="ID_MISSION_WINGS_DONE",
			--Replace={"ID_MISSION4_ID"}})
					V.Step=2
				end
			end
			},

			{2,
			 2,
			 "Waypoint",
			 function(V, Data)
				-- Check player position; if near enough: make the wings hostile to each other
				if Data.Waypoint == V.WP1 then
					NGUI.ShowInfoText({
			Text="ID_MISSION004_START_FIGHT",
			Replace={"ID_MISSION4_ID"}})
			
					-- Add the wings to the corresponding enemy list
					NWing.AddEnemy({
			Wing=V.Wing1,
			Target=V.Wing2})
					NWing.AddEnemy({
			Wing=V.Wing2,
			Target=V.Wing1})
					
					-- Start the fight
					NWing.AddAction({
			Wing=V.Wing1,
			List=LIST_ACTIVE,
			First=1,
			Actions={{Type=AI_ACTION_ANGRIFF}}
					})
					NWing.AddAction({
			Wing=V.Wing2,
			List=LIST_ACTIVE,
			First=1,
			Actions={{Type=AI_ACTION_ANGRIFF}}
					})
				
					-- Mark wing 2 as mission object
					NObject.SetMissionFlag({
			Object=V.Wing2,
			Set=1})
					NPlayer.SelectTarget({Object=V.Wing2})
			
					V.Step=3
				else
					--NGUI.ShowInfoText({
			--Text="ID_MISSION004_NOT_CLOSE_ENOUGH",
			--Replace={"ID_MISSION4_ID"}})
				end
			end
			},

			{2,
			 4,
			 "System",
			 function(V, Data)
				if Data.State == LEAVE_SYSTEM then
					-- Destroy Wing1 and Wing2
					NWing.Destroy({Wing=V.Wing1})
					NWing.Destroy({Wing=V.Wing2})
			
					-- Mark mission as failed
					NMission.SetState({State=MSTATE_FAILED})
					V.Step=99
				end
			end
			},

			{2,
			 4,
			 "Wing",
			 function(V, Data)
				-- Mark mission as failed when Wing1 gets destroyed
				if Data.Wing==V.Wing1 and Data.Event==WING_DESTROYED then
					NMission.SetState({State=MSTATE_FAILED})
					-- Wing2 leaves systems
					NWing.AddAction({
			Wing=V.Wing2,
			List=LIST_ACTIVE,
			First=1,
			Actions={{Type=AI_ACTION_SOFORTSPRUNG}}
					})
					NObject.SetMissionFlag({
			Object=V.Wing1,
			Set=0})
					NObject.SetMissionFlag({
			Object=V.Wing2,
			Set=0})
					V.Step=99
				end
			
				-- Mark mission as achieved when Wing2 gets destroyed
				if Data.Wing==V.Wing2 and Data.Event==WING_DESTROYED then
					NMission.SetState({State=MSTATE_ACHIEVED})
					-- Wing1 starts its standard action
					NWing.AddAction({
			Wing=V.Wing1,
			List=LIST_ACTIVE,
			First=1,
			Actions={{Type=AI_ACTION_STANDARD}}
					})
					NObject.SetMissionFlag({
			Object=V.Wing1,
			Set=0})
					NObject.SetMissionFlag({
			Object=V.Wing2,
			Set=0})
					V.Step=99
				end
			end
			}
		}
	}
)