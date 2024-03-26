---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuyou.
--- DateTime: 2024/3/23 23:55
---
local L = AceLibrary("AceLocale-2.2"):new("MasterLoot")
MasterLootFrame = {}
MasterLootFrame.playerName = UnitName("player")
MasterLootFrame.DropDown = AceLibrary("Dewdrop-2.0")
MasterLootFrame.isRaid =  GetNumRaidMembers() > 0 and true or false
MasterLootFrame.prefix =  MasterLootFrame.isRaid  and "raid" or "party"
MasterLootFrame.channelChat = MasterLootFrame.isRaid and "RAID" or "PARTY"

----- Menu exhibition -----
function MasterLootFrame:SetupFrame()
    --local icon, name, quantity, quality = GetLootSlotInfo(LootFrame.selectedSlot)
    --if quality < 1 then
    --    GiveMasterLoot(LootFrame.selectedSlot,  self:GetMLID(UnitName("player")))
    --    return
    --end

    self.DropDown:Open(
            UIParent,
            'children',
            function(level, value)
                self:CreateFrame(level, value)
            end,
            'cursorX', true,
            'cursorY', true
            )
end
function MasterLootFrame:CreateFrame(level, value)
    if level == 1 then
        self:CreateItem()
        ------------------------------------
        self:CreateUnitDropDown("player")
        for _, SelectUnite in MasterLoot.opt.PriorityList do
            self:CreateUnitDropDown(SelectUnite)
        end
        ------------------------------------
        self:GetEligibleCandidateIndexList()
        self:GetEligibleCandidateByClass()
        ------------------------------------
        self:CreateRandomRollDropDown()
        ------------------------------------
        self:CreateClassListDropDown(classList)
    elseif level == 2 then
        self:CreateClassListPlayerDropDown(value)
    end
end
----------------------------------------------------------------------
function LinkToID(link)
    if not link then return nil end
    return string.gsub(link,".-\124H([^\124]*)\124h.*", "%1")
end
function MasterLootFrame:CreateItem()
    local icon, name, quantity, quality = GetLootSlotInfo(LootFrame.selectedSlot)
    local LootSlotLink = GetLootSlotLink(LootFrame.selectedSlot)
    local link = LinkToID(LootSlotLink)
    if not link then return nil end
    self.DropDown:AddLine(
            'text', string.format("%s%s%s|r", tonumber(quantity) > 1 and tostring(quantity).."x" or "", ITEM_QUALITY_COLORS[quality].hex, name),
            'icon', icon,
            'iconWidth', 20,
            'iconHeight', 20,
            'tooltipFunc', GameTooltip.SetHyperlink,
            'tooltipArg1', GameTooltip ,
            'tooltipArg2', link,
            'func', function()
                        self:StartRoll(LootSlotLink)
                    end)
end
function MasterLootFrame:StartRoll(LootItemLink)
    local message =  string.format(L["开始ROLL"], LootItemLink )
    SendChatMessage(message, self.channelChat)
end
----------------------------------------------------------------------
function MasterLootFrame:CreateUnitDropDown(inputName)
    if not inputName then return end
    local UnitNameText = inputName == "player" and self.playerName or inputName
    local UnitMLCIndec = GetMasterLootCandidateIndex(UnitNameText)
    UnitNameText = inputName == "player" and L["自己"] or inputName

    self.DropDown:AddLine(
            'text', "|cFFBBBBBB"..L["偷偷分给"]..UnitNameText,
            'icon', "Interface\\GossipFrame\\VendorGossipIcon",
            'iconWidth', 20,
            'iconHeight', 20,
            'closeWhenClicked', true,
            'func', function()
                self:GiveLootToCandidate(L["偷偷分给"],nil, UnitMLCIndec)
            end)
end
----------------------------------------------------------------------
function MasterLootFrame:GetEligibleCandidateIndexList()
    --[[
    EligibleCandidateIndexList(key, value)
    key = RaidRosterIndex Which use to get GetRaidRosterInfo(value) max=GetNumRaidMembers()
    value = MasterLootCandidateIndex  witch use to get GetMasterLootCandidate(key) also is "raid"..key
    ]]
    self.EligibleCandidateIndexList = {}
    local RaidRosterIndex, MasterLootCandidateIndex
    for i = 1, 40 do
        local name = GetMasterLootCandidate(i)
        if name then
            MasterLootCandidateIndex = i
            RaidRosterIndex = GetRaidRosterIndex(name)
            MasterLoot:LevelDebug(2,
                    format("EligibleCandidateIndexList insert <%s=%s> for %s",
                            tostring(RaidRosterIndex), tostring(MasterLootCandidateIndex),tostring(name)))
            table.insert(self.EligibleCandidateIndexList, RaidRosterIndex, MasterLootCandidateIndex)
        end
    end
end
function GetRaidRosterIndex(name)
    for i = 1, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) == name then
            return i
        end
    end
end
function GetMasterLootCandidateIndex(name)
    for i = 1, 40 do
        if GetMasterLootCandidate(i) == name then
            return i
        end
    end
end
function MasterLootFrame:GetEligibleCandidateByClass()
    --[[
    EligibleCandidateByClass[classNameColored] =  {RaidRosterIndex,MasterLootCandidateIndex,targetNameColored}
    ]]

    self.EligibleCandidateByClass = {}
    for i, v in self.EligibleCandidateIndexList do
        local classNameColored, targetNameColored = self:GetClassNameWithColors(i)
        if classNameColored and targetNameColored then
            if not self.EligibleCandidateByClass[classNameColored] then
                self.EligibleCandidateByClass[classNameColored] = {}
            end
            local ECBC_ELEMENT = {i,v,targetNameColored}
            MasterLoot:LevelDebug(2,
                    format("EligibleCandidateByClass[%s] insert <%s,%s,%s> ",
                            tostring(classNameColored), tostring(ECBC_ELEMENT[1]), tostring(ECBC_ELEMENT[2]), tostring(ECBC_ELEMENT[3])
                            )
            )
            table.insert(self.EligibleCandidateByClass[classNameColored], ECBC_ELEMENT)
        end
    end
end
function MasterLootFrame:GetClassNameWithColors(Index)
    --[[
    Index is the index for GetRaidRosterInfo max=GetNumRaidMembers()
    ]]
    MasterLoot:LevelDebug(2,
            format("GetClassNameWithColors with %s", tostring(Index)))
    local name, class, fileName, _
    if self.isRaid then
        name, _, _, _, class, fileName, _, _ = GetRaidRosterInfo(Index)
    else
        name = UnitName(self.prefix..Index)
        class, fileName = UnitClass(self.prefix..Index)
    end
    MasterLoot:LevelDebug(2,
            format("GetRaidRosterInfo name=%s, class=%s, fileName=%s ",
                    tostring(name),tostring(class),tostring(fileName)))
    if not name then
        return
    end
    local c = RAID_CLASS_COLORS[fileName]
    local classhexe = string.format("%2x%2x%2x", c.r*255, c.g*255, c.b*255)
    local classNameWithColors = string.format("|cff%s%s|r",  classhexe,  class)
    local targetNameWithColors = string.format("|cff%s%s|r",  classhexe, name)
    return classNameWithColors, targetNameWithColors
end
----------------------------------------------------------------------
function MasterLootFrame:CreateRandomRollDropDown()
    self.DropDown:AddLine(
            'text', L["全团随机分配"],
            'icon', "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
            'iconWidth', 20,
            'iconHeight', 20,
            'closeWhenClicked', true,
            'func', function() self:GiveLootToRandomCandidate() end)
end
function MasterLootFrame:GiveLootToRandomCandidate(selectedSlot)
    local maxiNumRaidMembers = GetTableSize(self.EligibleCandidateIndexList)
    --local lastRRtime = GetTime()
    local RandomCandidateframe = CreateFrame("frame")
    RandomCandidateframe:RegisterEvent("CHAT_MSG_SYSTEM")
    RandomCandidateframe:SetScript("OnEvent", function()
        --if GetTime() - lastRRtime > 5 then return end
        local startRollIndex = string.find(arg1,"%d+")
        local _, endRollIndex = string.find(arg1, "%d+", startRollIndex)
        local roll = tonumber(string.sub(arg1, startRollIndex, endRollIndex))

        local winnerRaidRosterIndex, winnerRaidIndex = GetTableElement(self.EligibleCandidateIndexList,roll)
        local winnerClass, winnerName = self:GetClassNameWithColors(winnerRaidRosterIndex)
        MasterLoot:LevelDebug(2,
                format("RaidRoll winner is  : <%s // %s> at position  %s",
                        tostring(winnerClass), tostring(winnerName), tostring(winnerRaidIndex)))
        self:GiveLootToCandidate(L["全团随机获胜"], winnerRaidRosterIndex,winnerRaidIndex, winnerName, winnerClass, selectedSlot)
        RandomCandidateframe:UnregisterAllEvents()
    end)
    RandomRoll(1, maxiNumRaidMembers)

end
function MasterLootFrame:GetRaidIRollWinner(rollGet)
    local index, naame = GetTableElement(rollGet)
    MasterLoot:LevelDebug(2, format("RR naame  got : <%s> ", tostring(naame)))
    local winnerName = GetMasterLootCandidate(index)
    MasterLoot:LevelDebug(2, format("RR winnerName  got : <%s> ", tostring(winnerName)))
    if  winnerName ~= naame then
        return
    end
    return winnerName, index
end
function GetTableSize(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end
function GetTableElement(T,PO)
    local count = 0
    for i, v in T do
        count = count + 1
        if count == PO then
            return i, v
        end
    end
end

----------------------------------------------------------------------
function MasterLootFrame:CreateClassListDropDown()
    for k, v in self.EligibleCandidateByClass do
        self.DropDown:AddLine(
                'text', k,
                'hasArrow', true,
                'value', v)
    end
end
----------------------------------------------------------------------
function MasterLootFrame:CreateClassListPlayerDropDown(value)
    for _, v in value do
        local CandidateRRosterIndex = v[1]
        local CandidateMLCIndex = v[2]
        local CandidateWithColors = v[3]
        local CandidateClass = self:GetClassNameWithColors(CandidateRRosterIndex)
        self.DropDown:AddLine(
                'text', CandidateWithColors,
                'closeWhenClicked', true,
                'tooltipFunc', GameTooltip.SetUnit,
                'tooltipArg1', GameTooltip ,
                'tooltipArg2',self.prefix..CandidateMLCIndex ,
                'func', function()
                    self:GiveLootToCandidate(
                            L["定向获胜"], CandidateRRosterIndex, CandidateMLCIndex, CandidateWithColors, CandidateClass)
                end)
    end
end

----------------------------------------------------------------------
function MasterLootFrame:GiveLootToCandidate(
        mode, _, targetMLCIndex, targetNameWithColors, targetClassWithColors, selectedSlot)
    --targetRosterIndex
    local sS = selectedSlot and selectedSlot or LootFrame.selectedSlot


    if mode==L["偷偷分给"] then
        GiveMasterLoot(sS, targetMLCIndex)
        return
    end

    local message =  string.format("%s  %s",
            L["小皮箱队长分配助手"],
            string.format(tostring(mode),
                    tostring(targetClassWithColors),
                    tostring(targetNameWithColors),
                    tostring(GetLootSlotLink(sS)
                    )
            )
    )
    GiveMasterLoot(sS, targetMLCIndex)
    SendChatMessage(message, self.channelChat)
end

----------------------------------------------------------------------
function MasterLootFrame:AutoFunction()
    for li = 1, GetNumLootItems() do
        local _, name, quantity, quality = GetLootSlotInfo(li)
        --MasterLoot:LevelDebug(2,
        --        format("GetLootSlotInfo: <%s // %s // %s>",
        --                tostring(name), tostring(quantity), tostring(quality)))
        local UnitMLCIndec = GetMasterLootCandidateIndex(self.playerName)
        if  quantity ~=0  then
            MasterLoot:LevelDebug(2,
                    format("GetLootSlotInfo: <%s // %s // %s>",
                            tostring(name), tostring(quantity), tostring(quality)))
            if  quality <= 1 then
                if MasterLoot.opt.AutoLoot  then
                    self:GiveLootToCandidate(L["偷偷分给"],nil, UnitMLCIndec,nil,nil,nil)
                elseif MasterLoot.opt.AutoRR then
                    self:GetEligibleCandidateIndexList()
                    self:GiveLootToRandomCandidate(li)
                end

            end
        end
    end
end