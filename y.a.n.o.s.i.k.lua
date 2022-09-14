--@name Y.A.N.O.S.I.K
--@author
--@shared 

if SERVER then
    hook.add("PlayerEnteredVehicle", "pev", function(ply, veh, num)
        enableHud(veh:getDriver(), true)
    end)
    
    hook.add("PlayerLeaveVehicle", "plv", function(ply, veh)
        enableHud(veh:getDriver(), false)
    end)
    
    timer.create("S-czej",0.1, 0, function()
        local entWeldedToVel = chip():isWeldedTo()
            
        if chip():isWeldedTo():getClass() != "gmod_sent_vehicle_fphysics_base" then
            error("Na samochodzie to daj")
        end
            
        net.start("weldcheck")
        net.writeEntity(entWeldedToVel)
        net.send()
    end)
end

if CLIENT then
    local vehicle
    local vehicleVel = 0
    
    timer.create("C-czej", 0.1, 0, function()
        net.receive("weldcheck", function()
            vehicle = net.readEntity()
            vehicleVel = math.round(vehicle:getLocalVelocity():getLength() * 3600 * 0.0000254)
        end)
    end)
    
    local boolAlarm = false
    timer.create("alarm", 0.276, 0, function()
        if boolAlarm then
            vehicle:emitSound("buttons/blip2.wav", 75, 110, 1, 0)
        end
    end)
    
    local radaryDanger = {}
    timer.create("radarydanger", 0.1, 0, function()
        if table.count(radaryDanger) > 0 then
            boolAlarm = true
            timer.unpause("alarm")
        else
            boolAlarm = false
            timer.pause("alarm")
        end
    end)
    
    hook.add("hudconnected", "HUDConnect", function(ent, ply)
        hook.add("drawhud", "HUD", function()
            local plyPos = ply:getPos()
            // find in cone todo
            local radary = find.byModel("models/maxofs2d/camera.mdl")
            local resX, resY = render.getResolution()
            
            for k, radar in ipairs(radary) do
                radarClass = radar:getClass()
                if radarClass == "prop_physics" or radarClass == "starfall_processor" then
                    local radarPos = radar:getPos()
                    local radarPosToScreen = radarPos:toScreen()
                    
                    local radarDist = math.round(plyPos:getDistance(radarPos))
                    //push
                    render.pushViewMatrix({type = "2D"})
                    
                    if radarDist <= vehicleVel*50 and vehicleVel > 50 then
                        if table.count(radaryDanger) == 0 then
                            table.insert(radaryDanger, radar)
                        end
                        
                        render.setColor(Color(255,0,0))
                        render.drawCircle(radarPosToScreen["x"], radarPosToScreen["y"] -5, 67)
                        render.drawCircle(radarPosToScreen["x"], radarPosToScreen["y"] -5, 70)
                        render.drawCircle(radarPosToScreen["x"], radarPosToScreen["y"] -5, 73)
                        
                        render.setFont("DermaLarge")
                        render.drawText(radarPosToScreen["x"]+90, radarPosToScreen["y"] -5, "ZWOLNIJ!!!", 0)
                    else
                        if table.count(radaryDanger) > 0 then
                            table.removeByValue(radaryDanger, radar)
                        end
                        
                        render.setColor(Color(0,50,255))
                        render.drawCircle(radarPosToScreen["x"], radarPosToScreen["y"] -5, radarDist/(radarDist*0.05))
                    end
                    render.popViewMatrix()
                    //pop
                end
            end
        end)
    end)
end