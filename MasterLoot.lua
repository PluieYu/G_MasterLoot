---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by YU.
--- DateTime: 2024/3/23 20:26
---


MasterLoot = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0","AceModuleCore-2.0","AceComm-2.0","AceDB-2.0","AceDebug-2.0","AceConsole-2.0","FuBarPlugin-2.0", "AceHook-2.1")
local L = AceLibrary("AceLocale-2.2"):new("MasterLoot")

local _G = getfenv(0)



function MasterLoot:OnInitialize()
    self:SetDebugLevel(3)
    self:SetDebugging(true)
    self:RegisterDB("MasterLootDB")
end

function MasterLoot:OnProfileEnable()
    self.opt = self.db.profile
end

function MasterLoot:OnEnable()

    --name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(raidIndex)
    --local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(5)
    --self:LevelDebug(2, format("name: <%s>", tostring(name)))
    --self:LevelDebug(2, format("rank: <%s>", tostring(rank)))
    --self:LevelDebug(2, format("subgroup: <%s>", tostring(subgroup)))
    --self:LevelDebug(2, format("level: <%s>", tostring(level)))
    --self:LevelDebug(2, format("class: <%s>", tostring(class)))
    --self:LevelDebug(2, format("fileName: <%s>", tostring(fileName)))
    --self:LevelDebug(2, format("zone: <%s>", tostring(zone)))
    --

    self:Hook("LootFrame_OnEvent","OnEvent", true)
end
    --self:RegisterEvent("")

function MasterLoot:OnEvent(event)
    local method, id = GetLootMethod()
    if method ~= 'master' or id ~= 0 then
        return self.hooks.LootFrame_OnEvent(event)
    end
    if event == "OPEN_MASTER_LOOT_LIST" then
        MasterLootFrame:SetupFrame()
        return
    end
    return self.hooks.LootFrame_OnEvent(event)
end

function MasterLoot:OnDisable()
end




