source "lua/mission/MissionLib.lua"

NScript.Register(
	{
		Name = "Lost container",
		Group = 0,
		Type = MTYPE_USER_TERMINAL,

		Transitions = {
			{
                nil,
			 nil,
			 "Init",
			 function(V, Data)
			                    if MissionLib.GetStarSystemId() == 8 then
			                        return {Ready = true}
			                    end
			                    return {Ready = false}
			                end
			},

			{nil,
			 nil,
			 "Create",
			 function(V, Data)
			                    V.Reward = 1111  -- Reward for the mission
			                end
			},

			{nil,
			 nil,
			 "Subtype",
			 function(V, Data)
			                    return {Subtype = SUBTYPE_RESCUE}
			                end
			},

			{nil,
			 nil,
			 "MissionStart",
			 function(V, Data)
			                    NStarSystem.SetAsMissionTarget({System = MissionLib.GetStarSystemId(),
			                                                    Set = true})  -- Marks the current star system as mission target
			                    MissionLib.LogUpdateStory()  -- Display "new mission" message
			                    V.Step = 1
			                end
			},

			{1,
			 nil,
			 "Achieved",
			 function(V, Data)
			                    V.Step = 0
			                    return {Credits = V.Reward,
			                            Timeout = -1}  -- Player receives the defined reward, mission cannot be played again (timeout -1)
			                end
			},

			{1,
			 nil,
			 "Failed",
			 function(V, Data)
			                    V.Step = 0
			                    return {Timeout = 0}  -- Mission can be restarted immediately
			                end
			},

			{nil,
			 2,
			 "Text",
			 function(V, Data)
			                    return {Header = "ID_MISSION001_HEADER",
			                            Client = "ID_MISSION001_CLIENT",
			                            Text = "ID_MISSION001_TEXT",
			                            Credits = V.Reward}
			                end
			},

			{1,
			 1,
			 "Station",
			 function(V, Data)
			                    if Data.Enter == false then
			                        V.Container = NContainer.Create({Type = CONTAINER_SPACE,
			                                                         Size = CONTAINER_SMALL,
			                                                         PosDesc = POSDESCR_TRADESTATION1}).Container
			                        NContainer.Equip({Container = V.Container,
			                                          Goods = "ID_MISSION001_GOODS"})
			                        V.Step = 2
			                        V.PlayerHasContainer = false
			                    end
			                end
			},

			{2,
			 nil,
			 "Grab",
			 function(V, Data)
			                    if V.Container == Data.Container and Data.HasGrabbed then
			                        V.Step = 3
			                        MissionLib.LogUpdateTask()
			                        V.PlayerHasContainer = true
			                    end
			                end
			},

			{2,
			 3,
			 "Container",
			 function(V, Data)
			                    if V.Container == Data.Container and Data.Action == CONTAINER_DESTROYED then
			                        NMission.SetState({State = MSTATE_FAILED})
			                        V.Step = 99
			                    end
			                end
			},

			{3,
			 nil,
			 "Station",
			 function(V, Data)
			                    if Data.Enter then
			                        if V.PlayerHasContainer then
			                            NContainer.Destroy({Container = V.Container})
			                            NMission.SetState({State = MSTATE_ACHIEVED})
			                            V.Step = 99
			                        end
			                    end
			                end
			}
		}
	}
)