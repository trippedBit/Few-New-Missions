source "lua/mission/MissionLib.lua"

NScript.Register(
	{
		Name = "Planet race",
		Group = 0,
		Type = MTYPE_USER_TERMINAL,

		Transitions = {
			{nil,
			 nil,
			 "Init",
			 function(V, Data)
				if MissionLib.GetStarSystemId() == 8 then
					--NGUI.ShowInfoText({
						--Text="ID_MISSION_INIT",
						--Replace={"ID_MISSION5_ID"}})
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
					--Replace={"ID_MISSION5_ID"}})
				V.Reward=NPlayer.StandardReward({Factor=1}).Credits
			end
			},

			{nil,
			 nil,
			 "Subtype",
			 function(V, Data)
				--NGUI.ShowInfoText({
					--Text="ID_MISSION_SUBTYPE",
					--Replace={"ID_MISSION5_ID"}})
				return {Subtype = SUBTYPE_POLITICAL}
			end
			},

			{nil,
			 nil,
			 "MissionStart",
			 function(V, Data)
				NStarSystem.SetAsMissionTarget({
					System = MissionLib.GetStarSystemId(),
					Set = true})  -- Marks the current star system as mission target
				MissionLib.LogUpdateStory()  -- Display "new mission" message
				V.Step = 1
			end
			},

			{1,
			 nil,
			 "Achieved",
			 function(V, Data)
				NGUI.ShowInfoText({
					Text="ID_MISSION_ACHIEVED",
					Replace={"ID_MISSION5_ID"}})
				V.Step=0
				return {
					Credits=V.Reward,
					Timeout=5}
			end
			},

			{1,
			 nil,
			 "Failed",
			 function(V, Data)
				NGUI.ShowInfoText({
					Text="ID_MISSION_FAILED",
					Replace={"ID_MISSION5_ID"}})
				
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
					--Replace={"ID_MISSION5_ID"}})
				return {
					Header="ID_MISSION005_HEADER",
			                    		Client="ID_MISSION005_CLIENT",
			                    		Text="ID_MISSION005_TEXT",
			                    		Credits=V.Reward}
			end
			},

			{1,
			 1,
			 "Station",
			 function(V, Data)
				if Data.Enter == false then
					--NGUI.ShowInfoText({
						--Text="ID_MISSION_CREATE_WAYPOINTS",
						--Replace={"ID_MISSION5_ID"}})
					-- Create wing as time tracker
					V.Wing1=NWing.Create({
						WingType=WINGTYPE_FREIGHTER600CAP,
						Number=1,
						LevelOffset=0,
						Race=RACE_RANDOM,
						PosType=POSDESCR_EXPLICIT,
						Position={-5000,-4500,-7000}}).Wing
					V.Wing2=NWing.Create({
						WingType=WINGTYPE_FREIGHTER600CAP,
						Number=1,
						LevelOffset=0,
						Race=RACE_RANDOM,
						PosType=POSDESCR_EXPLICIT,
						Position={-8000,-4500,-10200}}).Wing
					V.Wing3=NWing.Create({
						WingType=WINGTYPE_FREIGHTER600CAP,
						Number=1,
						LevelOffset=0,
						Race=RACE_RANDOM,
						PosType=POSDESCR_EXPLICIT,
						Position={-6500,-6500,-25000}}).Wing
			
					MissionLib.SetWingName(
						V.Wing1,
						"ID_MISSION005_CLIENT")
					MissionLib.SetWingName(
						V.Wing2,
						"ID_MISSION005_CLIENT")
					MissionLib.SetWingName(
						V.Wing3,
						"ID_MISSION005_CLIENT")
			
					NWing.AddAction({
						Wing=V.Wing1,
						List=LIST_ACTIVE,
						First=1,
						Actions={{Type=AI_ACTION_WARTEN}}})
					NWing.AddAction({
						Wing=V.Wing2,
						List=LIST_ACTIVE,
						First=1,
						Actions={{Type=AI_ACTION_WARTEN}}})
					NWing.AddAction({
						Wing=V.Wing3,
						List=LIST_ACTIVE,
						First=1,
						Actions={{Type=AI_ACTION_WARTEN}}})
					
					-- Create rings
					V.Ring1=NObject.CreateRing({
						Position={-5000,-4500,-8000},
						Front={90,0,0}}).Ring
					V.Ring2=NObject.CreateRing({
						Position={-8000,-4500,-9500},
						Front={90,0,0}}).Ring
					V.Ring3=NObject.CreateRing({
						Position={-5000,-6500,-25000},
						Front={90,0,0}}).Ring
			
					-- Create waypoint in each ring
					V.Waypoint1=NWaypoint.Create({
						Position={-5000,-4500,-8000},
						Radius=10,
						Visible=true}).Waypoint
					V.Waypoint2=NWaypoint.Create({
						Position={-8000,-4500,-9500},
						Radius=10,
						Visible=true}).Waypoint
					V.Waypoint3=NWaypoint.Create({
						Position={-5000,-6500,-25000},
						Radius=10,
						Visible=true}).Waypoint
					
					-- Initialize variables for time measurement
					V.StartTime=0
					V.EndTime=0
					
					-- Select waypoint 1 as target
					NPlayer.SelectTarget({Object=V.Waypoint1}) -- crashes if used with rings, works for waypoints and wings
					
					--NGUI.ShowInfoText({
						--Text="ID_MISSION_CREATE_WAYPOINTS_DONE",
						--Replace={"ID_MISSION5_ID"}})
					V.Step=2
				end
			end
			},

			{2,
			 4,
			 "System",
			 function(V, Data)
				if Data.State == LEAVE_SYSTEM then
					-- Mark mission as failed
					NMission.SetState({State=MSTATE_FAILED})
					V.Step=99
				end
			end
			},

			{2,
			 4,
			 "Waypoint",
			 function(V, Data)
				if V.Step == 2 and Data.Leaving == true then
					--NGUI.ShowInfoText({
						--Text="ID_WAYPOINT_TRIGGERED"})
			
					-- first get end time
					-- start time has been initialized with 0 (zero) in the Station event
					-- if the player triggers waypoint 2 or 3 before triggering waypoint 1, the needed time is the current time and therefore too high to win
					if Data.Waypoint == V.Waypoint2 then
						--NGUI.ShowInfoText({
							--Text="ID_TIME_MEASUREMENT_END"})
						V.EndTime=NGame.GetTime({}).Time
			
						V.TimeDifference=V.EndTime-V.StartTime
						if V.TimeDifference < 30 then
							--NGUI.ShowInfoText({
								--Text="ID_TIME_BELOW_30"})
							MissionLib.SetWingName(V.Wing2, "ID_TIME_BELOW_30")
						else
							--NGUI.ShowInfoText({
								--Text="ID_TIME_ABOVE_30"})
							MissionLib.SetWingName(V.Wing2, "ID_TIME_ABOVE_30")
						end
					elseif Data.Waypoint == V.Waypoint3 then
						--NGUI.ShowInfoText({
							--Text="ID_TIME_MEASUREMENT_END"})
						V.EndTime=NGame.GetTime({}).Time
			
						V.TimeDifference=V.EndTime-V.StartTime
						if V.TimeDifference < 160 then  -- first place
							MissionLib.SetWingName(V.Wing3, "ID_TIME_BELOW_160")
							V.Reward=NPlayer.StandardReward({Factor=1}).Credits
							-- drop artefact as additional reward
							NContainer.Create({
								Type=CONTAINER_POSITION,
								Size=CONTAINER_ARTEFACT,
								Position={-5000,-6500,-25000}
							})
						elseif V.TimeDifference < 165 then  -- second place
							MissionLib.SetWingName(V.Wing3, "ID_TIME_BELOW_165")
							V.Reward=NPlayer.StandardReward({Factor=0.75}).Credits
							-- drop artefact as additional reward
							NContainer.Create({
								Type=CONTAINER_POSITION,
								Size=CONTAINER_ARTEFACT,
								Position={-5000,-6500,-25000}
							})
						elseif V.TimeDifference < 170 then  -- third place
							MissionLib.SetWingName(V.Wing3, "ID_TIME_BELOW_170")
							V.Reward=NPlayer.StandardReward({Factor=0.5}).Credits
						else
							MissionLib.SetWingName(V.Wing3, "ID_TIME_TOO_SLOW")
							V.Reward=NPlayer.StandardReward({Factor=0.25}).Credits
						end
			
						-- Mission done, mark it as achieved
						NWaypoint.Show({
							Waypoint=V.Waypoint1,
							Show=false
						})
						NWaypoint.Show({
							Waypoint=V.Waypoint2,
							Show=false
						})
						NWaypoint.Show({
							Waypoint=V.Waypoint3,
							Show=false
						})
						NMission.SetState({State=MSTATE_ACHIEVED})
					end
			
					-- now get start time
					if Data.Waypoint == V.Waypoint1 or Data.Waypoint == V.Waypoint2 then
						NGUI.ShowInfoText({
							Text="ID_TIME_MEASUREMENT_START"})
						V.StartTime=NGame.GetTime({}).Time
			
						-- select next ring
						if Data.Waypoint == V.Waypoint1 then
							-- select waypoint 2 as target
							NPlayer.SelectTarget({Object=V.Waypoint2}) -- crashes if used with rings, works for waypoints and wings
						else
							-- select waypoint 3 as target
							NPlayer.SelectTarget({Object=V.Waypoint3}) -- crashes if used with rings, works for waypoints and wings
						end
					end
				end
			end
			}
		}
	}
)