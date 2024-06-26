---
--- Documentation https://github.com/PluieYu/G_MasterLoot?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/23 21:25
---
--


MasterLoot = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0","AceModuleCore-2.0","AceComm-2.0","AceDB-2.0","AceDebug-2.0","AceConsole-2.0","FuBarPlugin-2.0", "AceHook-2.1")
local L = AceLibrary("AceLocale-2.2"):new("MasterLoot")

MasterLoot.hasIcon = "Interface\\Buttons\\UI-GroupLoot-Dice-Up"
MasterLoot.defaultMinimapPosition = 270
MasterLoot.hideWithoutStandby = true

function MasterLoot:OnInitialize()
    self:SetDebugLevel(3)
    self.Prefix =
    "|cffF5F54A["..base64:dec("5bCP55qu566x").."]|r|cff9482C9"..base64:dec("5Zui6Zif5Yqp5omL").."|r"
    --self:SetDebugging(true)
    self:RegisterDB("MasterLootDB")
    self:RegisterDefaults("profile", {
        ReservedPlayerList = {},
        ReservedItemList = {},
        AutoLoot = false,
        AutoRR = false,
        ItemQuality = 2,
    })
    self:OnProfileEnable()
    self:OnInitializeOption()
    self.MLOF = MasterLootOptionFrame
    self.MLOF:OnInitialize()
    self.OnMenuRequest = MasterLoot.options
    self:RegisterChatCommand({"/ML", "/MasterLoot"}, self.options)
    DEFAULT_CHAT_FRAME:AddMessage(self:BuildMessage(L["已加载"]))
end

function  MasterLoot:OnInitializeOption()
    self.options = {
        type = "group",
        args = {
            ExtraMode = {
                type = "group",
                name = L["额外拾取模式"] ,
                desc = L["额外拾取模式描述"] ,
                order =1,
                args = {
                    AutoLootToggle = {
                        type = "toggle",
                        name = L["通通归我"]    ,
                        desc = L["通通归我描述"],
                        order = 1,
                        isRadio = true,
                        get = function() return MasterLoot.opt.AutoLoot end,
                        set = function() MasterLoot:SetAutoLoot() end,
                    },
                    AutoRRToggle = {
                        type = "toggle",
                        name = L["见者有份"],
                        desc = L["见者有份描述"],
                        order = 2,
                        isRadio = true,
                        get = function() return MasterLoot.opt.AutoRR end,
                        set = function() MasterLoot:SetAutoRR() end,
                    },
                    ReservedItemToggle = {
                        type = "toggle",
                        name = L["值钱的归我"],
                        desc = L["值钱的归我描述"],
                        order = 3,
                        get = function() return MasterLoot:GetReservedItem() end,
                        set = function() MasterLoot:SetReservedItem() end,
                    },
                },
            },
            ExtraItemQuality = {
                type = "group",
                name = L["选定物品等级"],
                desc = L["选定物品等级描述"],
                order =2,
                args = {
                    PoorToggle = {
                        type = "toggle",
                        name = ITEM_QUALITY_COLORS[0].hex..ITEM_QUALITY0_DESC.."|r",
                        desc = ITEM_QUALITY_COLORS[0].hex..ITEM_QUALITY0_DESC.."|r",
                        order = 1,
                        isRadio = true,
                        get = function() return MasterLoot:GetItemQuality(0) end,
                        set = function() MasterLoot:SetItemQuality(0) end,
                    },
                    CommonToggle = {
                        type = "toggle",
                        name = ITEM_QUALITY_COLORS[1].hex..ITEM_QUALITY1_DESC.."|r",
                        desc = ITEM_QUALITY_COLORS[1].hex..ITEM_QUALITY0_DESC.."|r",
                        order = 2,
                        isRadio = true,
                        get = function() return MasterLoot:GetItemQuality(1) end,
                        set = function() MasterLoot:SetItemQuality(1) end,
                    },
                    UncommonToggle = {
                        type = "toggle",
                        name = ITEM_QUALITY_COLORS[2].hex..ITEM_QUALITY2_DESC.."|r",
                        desc = ITEM_QUALITY_COLORS[2].hex..ITEM_QUALITY0_DESC.."|r",
                        order = 3,
                        isRadio = true,
                        get = function() return MasterLoot:GetItemQuality(2) end,
                        set = function() MasterLoot:SetItemQuality(2) end,
                    },
                    RareToggle = {
                        type = "toggle",
                        name = ITEM_QUALITY_COLORS[3].hex..ITEM_QUALITY3_DESC.."|r",
                        desc = ITEM_QUALITY_COLORS[3].hex..ITEM_QUALITY0_DESC.."|r",
                        order = 4,
                        isRadio = true,
                        get = function() return MasterLoot:GetItemQuality(3) end,
                        set = function() MasterLoot:SetItemQuality(3) end,
                    },
                },

            },
            ExtraItemList = {
                type = "execute",
                name = L["值钱的物品"],
                desc = L["值钱的物品描述"],
                order =3,
                func = function() MasterLoot:ShowExtraItemList() end,
            },
            ExtraPlayerList = {
                type = "execute",
                name = L["快捷分配列表"],
                desc = L["快捷分配列表描述"],
                order =4,
                func = function() MasterLoot:ShowExtraPlayerList() end,
            },
        }
    }
end

function MasterLoot:OnProfileEnable()
    self.opt = self.db.profile
end

function MasterLoot:OnEnable()
    MasterLoot.MLF = MasterLootFrame
    self.MLF:OnEnable()
    self:Hook("LootFrame_OnEvent","OnEvent", true)
end

function MasterLoot:OnEvent(event)
    local method, id = GetLootMethod()
    if method ~= 'master' or id ~= 0 then
        return self.hooks.LootFrame_OnEvent(event)
    end

    self.MLF.isRaid =  GetNumRaidMembers() > 0 and true or false
    self.MLF.prefix =  self.MLF.isRaid  and "raid" or "party"
    self.MLF.channelChat = self.MLF.isRaid and "RAID" or "PARTY"
    if event == "LOOT_OPENED"  then
        for li = 1, GetNumLootItems() do
            local _, name, _, quality = GetLootSlotInfo(li) --quantity
            local LootSlotLink = GetLootSlotLink(li)
            local link = LinkToID(LootSlotLink)
            if not LootSlotIsCoin(li) then
                if self.opt.IsReserved and tContainsKey(MasterLoot.opt.ReservedItemList, name)  then
                    if MasterLoot.opt.ReservedItemList[name] == 0 then
                        MasterLoot.opt.ReservedItemList[name] = link
                    end
                    self:Print(L["偷偷分给"]..L["自己"])
                    self.MLF:GLTC(L["偷偷分给"], self.MLF.playerName,nil, nil, li)
                elseif quality <= self.opt.ItemQuality then
                    if  self.opt.AutoLoot then
                        self.MLF:GLTC(L["偷偷分给"], self.MLF.playerName,nil, nil, li)
                    elseif self.opt.AutoRR then
                        self.MLF:GetRandomCandidate(li) end
                end
            end
        end
    elseif event == "OPEN_MASTER_LOOT_LIST" then
        return self.MLF:SetupFrame()
    elseif event == "UPDATE_MASTER_LOOT_LIST" then
        return self.MLF:Refresh()
    end
    collectgarbage()
    return self.hooks.LootFrame_OnEvent(event)
end

function MasterLoot:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end

function MasterLoot:GetClassHex(fileName, class, name)
    local ColorfulName, ColorfulClassName = nil, nil
    local c = RAID_CLASS_COLORS[fileName]
    local classHex = string.format("%2x%2x%2x", c.r*255, c.g*255, c.b*255)
    if name then ColorfulName = string.format("|cff%s%s|r", classHex,  name) end
    if class then ColorfulClassName = string.format("|cff%s%s|r", classHex,  class) end
    return classHex, ColorfulClassName, ColorfulName
end
function MasterLoot:BuildMessage(TEXT, args1, args2 )
    local subMsg
    if args2 then
        subMsg = format(TEXT, args1, args2)
    elseif args1 then
        subMsg = format(TEXT, args1)
    else
        subMsg = TEXT
    end
    return format("%s %s", self.Prefix, subMsg)
end
------------------------------------------
---Option function
------------------------------------------
--模式--
function MasterLoot:SetAutoLoot()
    self.opt.AutoLoot = not self.opt.AutoLoot
    if self.opt.AutoLoot then
        self.opt.AutoRR = false
    end
    local message = string.format("%s:%s", L["通通归我"], self.opt.AutoLoot==true and L["已开启"] or L["已关闭"] )
    self:Print(message)
end
function MasterLoot:SetAutoRR()
    self.opt.AutoRR = not self.opt.AutoRR
    if self.opt.AutoRR then
        self.opt.AutoLoot = false
    end
    local message = string.format("%s:%s", L["见者有份"], self.opt.AutoRR==true and L["已开启"] or L["已关闭"] )
    self:Print(message)
end
function MasterLoot:GetReservedItem()
    return self.opt.IsReserved
end
function MasterLoot:SetReservedItem()
    self.opt.IsReserved = not self.opt.IsReserved
    local ReservedItem =  table.concat(self.opt.ReservedItemList,", ")
    local message1 = string.format("%s:%s", L["值钱的归我"], self.opt.IsReserved==true and L["已开启"] or L["已关闭"] )
    local message2 = string.format("%s:%s", L["值钱的物品"], ReservedItem)
    self:Print(message1)
    self:Print(message2)
end
--物品品级--
function MasterLoot:GetItemQuality(level)
    if self.opt.ItemQuality == level then
        return true
    else
        return false
    end
end
function MasterLoot:SetItemQuality(level)
    self.opt.ItemQuality = level
end
--值钱物品--
function MasterLoot:ShowExtraItemList()
        self.MLOF:SetupEILFrame()
end
function MasterLoot:CleanExtraItemList()
    wipe(MasterLoot.opt.ReservedItemList)
    self:Print(L["值钱的物品"]..L["已重置"])
end
function MasterLoot:RemoveExtraItem(value)
    if tContainsKey(MasterLoot.opt.ReservedItemList ,value) then
        MasterLoot.opt.ReservedItemList[value] = nil
        self:Print(value..L["已删除"])
    end
end

--快捷分配--
function MasterLoot:ShowExtraPlayerList()
    self.MLOF:SetupEPLFrame()
end
function MasterLoot:CleanExtraPlayerList()
    wipe(MasterLoot.opt.ReservedPlayerList)
    self:Print(L["快捷分配列表"]..L["已重置"])
end
function MasterLoot:AddTargetToExtraPlayerList()
    local targetName = UnitName("target")
    if not targetName then
        self:Print(L["你必须有目标"])
        return
    end
    self.opt.ReservedPlayerList[targetName] = 1
    self:Print(targetName .. L["已添加"])

end
function MasterLoot:RemoveExtraPlayer(value)
    if tContainsKey(MasterLoot.opt.ReservedPlayerList ,value) then
        MasterLoot.opt.ReservedPlayerList[value] = nil
        self:Print(value..L["已删除"])
    end
end




function tContains(table, item)
    local index = 1;
    while table[index] do
        if ( item == table[index] ) then
            return index
        end
        index = index + 1;
    end
    return nil;
end
function tContainsKey(table, item)
    for k, _ in pairs(table) do
        if  k == item then
            return true
        end
    end
    return false
end


