if SERVER then
    AddCSLuaFile()
end          

SWEP.PrintName = "Prop Shooter"
SWEP.Author = "amny4nm"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "amny4nm sweps"
SWEP.Base = "weapon_base"
SWEP.Instructions = "LMB - Shoot prop | RMB - Rocket Jump"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local randomProps = {
    "models/props_c17/oildrum001.mdl",
    "models/props_junk/watermelon01.mdl",
    "models/props_c17/FurnitureChair001a.mdl",
    "models/props_junk/wood_crate001a.mdl",
    "models/props_lab/huladoll.mdl",
    "models/props_c17/FurnitureTable002a.mdl",
    "models/props_c17/FurnitureFridge001a.mdl",
    "models/props_junk/trafficcone001a.mdl",
    "models/props_c17/oildrum001_explosive.mdl",
    "models/props_junk/garbage256_composite001a.mdl",
    "models/props_junk/metal_paintcan001a.mdl",
    "models/props_c17/FurnitureCouch001a.mdl",
    "models/props_junk/plasticbucket001a.mdl",
    "models/props_c17/FurnitureShelf001a.mdl",
    "models/props_junk/wood_crate002a.mdl",
    "models/props_wasteland/kitchen_shelf001a.mdl",
    "models/props_junk/PopCan01a.mdl",
    "models/props_wasteland/controlroom_desk001b.mdl",
    "models/props_c17/FurnitureDrawer001a.mdl",
    "models/props_lab/monitor01a.mdl",
    "models/props_junk/sawblade001a.mdl",
    "models/props_junk/propanecanister001a.mdl",
    "models/props_c17/Lockers001a.mdl",
    "models/props_c17/FurnitureBathtub001a.mdl",
    "models/props_lab/harddrive02.mdl",
    "models/maxofs2d/logo_gmod_b.mdl",
    "models/dog.mdl"
}

local randomMaterials = {
    "models/debug/debugwhite",
    "models/props_c17/metalladder001",
    "models/props_combine/metal_combinebridge001",
    "models/props_c17/furniturefabric003a",
    "models/props_lab/xencrystal_sheet",
    "models/props_pipes/GutterMetal01a",
    "models/wireframe",
    "models/weapons/v_crowbar/crowbar_cyl"
}

CreateConVar("prop_shooter_speed", 2000, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Projectile speed", 500, 5000)
CreateConVar("prop_shooter_delay", 0.2, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Fire delay", 0.05, 1)
CreateConVar("prop_shooter_fire", 10, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Fire chance (%)", 0, 100)
CreateConVar("prop_shooter_trail", 10, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Trail chance (%)", 0, 100)
CreateConVar("prop_shooter_color", 10, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Color chance (%)", 0, 100)
CreateConVar("prop_shooter_gravity", 5, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Antigravity chance (%)", 0, 100)
CreateConVar("prop_shooter_explode", 5, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Explosion chance (%)", 0, 100)
CreateConVar("prop_shooter_language", "ru", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Interface language (ru/en)")
CreateConVar("prop_shooter_material", 10, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Chance to apply a random material to props (0-100)")
CreateConVar("prop_shooter_rocketjump", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Enable Rocket Jump (1 = ON, 0 = OFF)")
CreateConVar("prop_shooter_old_rocketjump", 0, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Enable old Rocket Jump physics (1 = ON, 0 = OFF)")

if CLIENT then
    hook.Add("PopulateToolMenu", "PropShooterSettings", function()
        spawnmenu.AddToolMenuOption("Utilities", "Prop Shooter", "PropShooter", "Настройки", "", "", function(panel)
            panel:ClearControls()

            local lang = GetConVar("gmod_language"):GetString()
            local isRussian = (lang == "ru")

            panel:Help(isRussian and "Основные настройки" or "Main Settings")  
            panel:CheckBox(isRussian and "Включить рокет-джамп" or "Enable Rocket Jump", "prop_shooter_rocketjump")
                :SetTooltip(isRussian and "Позволяет отталкиваться от взрыва без урона."
                                         or "Allows you to propel yourself with explosions without taking damage.")  

            panel:NumSlider(isRussian and "Скорость пропов" or "Prop Speed", "prop_shooter_speed", 100, 5000, 0)
                :SetTooltip(isRussian and "Чем выше значение, тем быстрее летят пропы."
                                         or "Higher values make props fly faster.")  
            panel:NumSlider(isRussian and "Задержка выстрела" or "Fire Delay", "prop_shooter_delay", 0.1, 2, 1)
                :SetTooltip(isRussian and "Минимальное время между выстрелами."
                                         or "Minimum time between shots.")  
            panel:Help(isRussian and "Эффекты пропов" or "Prop Effects")  
            panel:NumSlider(isRussian and "Шанс поджога (%)" or "Fire Chance (%)", "prop_shooter_fire", 0, 100, 0)
                :SetTooltip(isRussian and "Шанс того, что проп загорится при выстреле."
                                         or "Chance for a prop to catch fire when shot.")  
            panel:NumSlider(isRussian and "Шанс следа (%)" or "Trail Chance (%)", "prop_shooter_trail", 0, 100, 0)
                :SetTooltip(isRussian and "Шанс, что проп оставит за собой красивый след."
                                         or "Chance for a prop to leave a trail behind.")  
            panel:NumSlider(isRussian and "Шанс случайного цвета (%)" or "Random Color Chance (%)", "prop_shooter_color", 0, 100, 0)
                :SetTooltip(isRussian and "Шанс, что проп получит случайный цвет."
                                         or "Chance for a prop to get a random color.")  
            panel:NumSlider(isRussian and "Шанс антигравитации (%)" or "Antigravity Chance (%)", "prop_shooter_gravity", 0, 100, 0)
                :SetTooltip(isRussian and "Шанс, что проп будет парить без гравитации."
                                         or "Chance for a prop to float without gravity.")  
            panel:NumSlider(isRussian and "Шанс взрыва при попадании (%)" or "Explosion Chance (%)", "prop_shooter_explode", 0, 100, 0)
                :SetTooltip(isRussian and "Шанс, что проп взорвётся при столкновении."
                                         or "Chance for a prop to explode on impact.")  
            panel:Help(isRussian and "Прочее" or "Misc.")
            panel:CheckBox(isRussian and "Старая физика рокет джамп" or "Old Rocket Jump Physics", "prop_shooter_old_rocketjump")
                :SetTooltip(isRussian and "Старая физика просто подкидывает вверх игрока, новая же откидывает в противоположную сторону от взрыва и ускоряет игрока" 
                             or "The old physics just throws the player up, the new one throws the player in the opposite direction from the explosion and accelerates the player")
        end)
    end)
end

function SWEP:Initialize()
    self:SetHoldType("pistol")
    self.isRussian = (GetConVar("gmod_language"):GetString() == "ru")
end

local function RemovePropWithDissolve(ent, time)
    if not IsValid(ent) then return end

    timer.Simple(time, function()
        if IsValid(ent) then
            local dissolve = ents.Create("env_entity_dissolver")
            dissolve:SetPos(ent:GetPos())
            dissolve:SetKeyValue("dissolvetype", "3")
            dissolve:Spawn()
            dissolve:Fire("Dissolve", "", 0)
            ent:Remove()
        end
    end)
end


local maxSelectDistance = 150

function SWEP:Think()
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if ply:KeyPressed(IN_USE) then
        local trace = ply:GetEyeTrace()
        if trace.Hit and IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_physics" then
            if ply:GetPos():Distance(trace.Entity:GetPos()) <= maxSelectDistance then
                self.SelectedProp = trace.Entity:GetModel()
                ply:EmitSound("buttons/button15.wav")
            end
        elseif trace.HitWorld and self.SelectedProp ~= nil then
            self.SelectedProp = nil
            ply:EmitSound("buttons/button19.wav")
        end
    end
end

function SWEP:PrimaryAttack()
    if not SERVER then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    local prop = ents.Create("prop_physics")
    if not IsValid(prop) then return end

    local model = self.SelectedProp or table.Random(randomProps)
    prop:SetModel(model)

    prop:SetPos(ply:EyePos() + (ply:GetAimVector() * 30))
    prop:SetAngles(Angle(0, ply:EyeAngles().y, 0))
    prop:Spawn()

    -- Физика пропа
    local phys = prop:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetVelocity(ply:GetAimVector() * GetConVar("prop_shooter_speed"):GetInt())
    end

    if IsValid(phys) then
        local speedLimit = 5000
        local velocity = ply:GetAimVector() * GetConVar("prop_shooter_speed"):GetInt()
    
        if velocity:Length() > speedLimit then
            velocity = velocity:GetNormalized() * speedLimit
        end
    
        phys:SetVelocity(velocity)
    end

    if math.random(1, 100) <= GetConVar("prop_shooter_fire"):GetInt() then
        prop:Ignite(5)
    end

    if math.random(1, 100) <= GetConVar("prop_shooter_trail"):GetInt() then
        util.SpriteTrail(prop, 0, Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)), false, 15, 1, 2, 1/(15+1)*0.5, "trails/laser.vmt")
    end

    if math.random(1, 100) <= GetConVar("prop_shooter_color"):GetInt() then
        prop:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
    end

    if math.random(1, 100) <= GetConVar("prop_shooter_gravity"):GetInt() then
        local phys = prop:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableGravity(false)
        end
    end
    
    ply:EmitSound("garrysmod/balloon_pop_cute.wav")

    if math.random(1, 100) <= GetConVar("prop_shooter_explode"):GetInt() then
        prop:AddCallback("PhysicsCollide", function(ent, data)
            local explosion = ents.Create("env_explosion")
            explosion:SetPos(ent:GetPos())
            explosion:SetOwner(ply)
            explosion:Spawn()
            explosion:SetKeyValue("iMagnitude", "100")
            explosion:Fire("Explode", 0, 0)
            ent:Remove()
        end)
    end

    RemovePropWithDissolve(prop, 10)

    if math.random(1, 100) <= GetConVar("prop_shooter_material"):GetInt() then
        local material = table.Random(randomMaterials)
        prop:SetMaterial(material)
    end

    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

    self:SetNextPrimaryFire(CurTime() + GetConVar("prop_shooter_delay"):GetFloat())
end

function SWEP:SecondaryAttack()
    if not SERVER then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local lang = GetConVar("gmod_language"):GetString()
    local isRussian = (lang == "ru")

    if GetConVar("prop_shooter_rocketjump"):GetInt() == 0 then
        ply:ChatPrint(isRussian and "Рокет джамп отключён сервером!" 
                                or "Rocket Jump is disabled by the server!")
        return
    end

    local prop = ents.Create("prop_physics")
    if not IsValid(prop) then return end

    prop:SetModel("models/props_junk/watermelon01.mdl")
    prop:SetPos(ply:EyePos() + (ply:GetAimVector() * 30))
    prop:SetAngles(Angle(0, ply:EyeAngles().y, 0))
    prop:Spawn()
    prop:SetCollisionGroup(COLLISION_GROUP_WORLD)

    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

    local phys = prop:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * GetConVar("prop_shooter_speed"):GetInt())
    end

    prop:AddCallback("PhysicsCollide", function(ent, data)
        local explosion = ents.Create("env_explosion")
        explosion:SetPos(ent:GetPos())
        explosion:SetOwner(ply)
        explosion:Spawn()
        explosion:SetKeyValue("iMagnitude", "0")
        explosion:SetKeyValue("fireballsprite", "sprites/zerogxplode.spr")
        explosion:Fire("Explode", 0, 0)

        local dist = ply:GetPos():Distance(ent:GetPos())
        if dist < 150 then
            if GetConVar("prop_shooter_old_rocketjump"):GetInt() == 1 then
                local jumpForce = Vector(0, 0, 600)
                ply:SetVelocity(jumpForce)
            else
                local dir = (ply:GetPos() - ent:GetPos()):GetNormalized()
                local force = dir * 800
                ply:SetVelocity(force)
            end
        end

        ent:Remove()
    end)
end

if CLIENT then
    local abilityIcons = {
        rocket_jump = "vgui/prop_shooter_rocketjump.png"
    }

    hook.Add("HUDPaint", "DrawAbilityIcon", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_prop_shooter" then return end

        local icon = abilityIcons["rocket_jump"]

        if icon then
            local iconSize = 96
            local x = (ScrW() / 2) - (iconSize / 2)
            local y = ScrH() - iconSize - 20

            surface.SetMaterial(Material(icon))
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(x, y, iconSize, iconSize)
        end
    end)
end
