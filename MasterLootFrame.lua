---
--- Documentation https://github.com/PluieYu/G_MasterLoot?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/23 21:25
---
local L = AceLibrary("AceLocale-2.2"):new("MasterLoot")
MasterLootFrame = {}
MasterLootFrame.DropDown = AceLibrary("Dewdrop-2.0")


function MasterLootFrame:OnEnable()
    self.playerName = UnitName("player")
    self.playerClass, self.playerFileName = UnitClass("player")
    self.lastRRtime = GetTime()
end

----------------------------------------------------------------------
function MasterLootFrame:SetupFrame()
    self.isRaid =  GetNumRaidMembers() > 0 and true or false
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
        ------------------------------------
        self:CreateItem()
        self:AddReservedItem()
        ------------------------------------
        self:CreateUnitDropDown()
        for su, _ in pairs(MasterLoot.opt.ReservedPlayerList) do
            self:CreateUnitDropDown(su)
        end
        ------------------------------------
        self:CreateRandomRollDropDown()
        ------------------------------------
        self:CreateClassListDropDown()
    elseif level == 2 then
        self:CreateClassListPlayerDropDown(value)
    end
end
----------------------------------------------------------------------
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
function MasterLootFrame:AddReservedItem(inputName)
    local icon, name, _, quality = GetLootSlotInfo(LootFrame.selectedSlot) --quantity
    local LootSlotLink = GetLootSlotLink(LootFrame.selectedSlot)
    local link = LinkToID(LootSlotLink)
    inputName = not inputName and self.playerName or inputName
    if not tContainsKey(MasterLoot.opt.ReservedItemList, name) then
        self.DropDown:AddLine(
                'text', string.format("%s %s%s|r", L["添加物品"], ITEM_QUALITY_COLORS[quality].hex, name),
                --'icon', "Interface\\GossipFrame\\VendorGossipIcon",
                'icon', icon,
                'iconWidth', 20,
                'iconHeight', 20,
                'closeWhenClicked', true,
                'tooltipFunc', GameTooltip.SetHyperlink,
                'tooltipArg1', GameTooltip ,
                'tooltipArg2', link,
                'func', function()
                    MasterLoot.opt.ReservedItemList[name] = link
                end)
    else
        self.DropDown:AddLine(
                'text', string.format("%s %s%s|r", L["移除物品"], ITEM_QUALITY_COLORS[quality].hex, name),
                'icon', icon,
                'iconWidth', 20,
                'iconHeight', 20,
                'closeWhenClicked', true,
                'tooltipFunc', GameTooltip.SetHyperlink,
                'tooltipArg1', GameTooltip ,
                'tooltipArg2', link,
                'func', function()
                    MasterLoot.opt.ReservedItemList[name] = nil
                end)
    end
    end

function MasterLootFrame:CreateUnitDropDown(inputName)
    local UnitNameText = inputName and inputName or L["自己"]
    inputName = not inputName and self.playerName or inputName
    self.DropDown:AddLine(
            'text', "|cFFBBBBBB"..L["偷偷分给"]..UnitNameText,
            'icon', "Interface\\GossipFrame\\VendorGossipIcon",
            'iconWidth', 20,
            'iconHeight', 20,
            'closeWhenClicked', true,
            'func', function()
                self:GLTC(L["偷偷分给"], inputName,nil, nil)
            end)
end
function MasterLootFrame:CreateRandomRollDropDown()
    self.DropDown:AddLine(
            'text', L["随机分配"],
            'icon', "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
            'iconWidth', 20,
            'iconHeight', 20,
            'closeWhenClicked', true,
            'func', function() self:GetRandomCandidate() end)
end
function MasterLootFrame:CreateClassListDropDown()
    local ECNL = self:GetECNL()
    for _, v in ipairs(ECNL) do
        MasterLoot:LevelDebug(2, format("CreateClassListDropDown ECNL is <%s>", tostring(v)))
    end
    -- EligibleCandidateNameListByClass, ClassOnName
    local ECNLBC, _ = self:ReformECNLBC(ECNL)
    --ctl = list of {CandidateName CandidateClass CandidateFileName}
    for _, ctl in pairs(ECNLBC) do
        local _, ColorfulClassName, _ = MasterLoot:GetClassHex(ctl[1][3], ctl[1][2], ctl[1][1])
        MasterLoot:LevelDebug(2, format("CreateClassListDropDown got className %s", tostring(ColorfulClassName)))
        self.DropDown:AddLine(
                'text', ColorfulClassName,
                'hasArrow', true,
                'value', ctl)
    end
end
function MasterLootFrame:CreateClassListPlayerDropDown(value)
    --ct = {CandidateName CandidateClass CandidateFileName}
    for _, ct in ipairs(value) do
        MasterLoot:LevelDebug(2,
                format("CreateClassListPlayerDropDown got is <%s %s %s>",
                        tostring(ct[1]), tostring(ct[2]),tostring(ct[3])))
        local CN = ct[1]
        --classHex, ColorfulClassName, ColorfulName
        local _, ColorfulClassName, ColorfulName = MasterLoot:GetClassHex(ct[3], ct[2], CN)
        local unite = self:GetRI(CN)

        self.DropDown:AddLine(
                'text', ColorfulName,
                'closeWhenClicked', true,
                'tooltipFunc', GameTooltip.SetUnit,
                'tooltipArg1', GameTooltip ,
                'tooltipArg2', unite,
                'func', function()
                    self:GLTC(
                            L["分给"], CN, ColorfulName, ColorfulClassName)
                end)
    end
end
function MasterLootFrame:Refresh()
    self.DropDown:Refresh()
end
----------------------------------------------------------------------
function LinkToID(link)
    if not link then return nil end
    return string.gsub(link,".-\124H([^\124]*)\124h.*", "%1")
end
-- Send item link to chat --
function MasterLootFrame:StartRoll(LootItemLink)
    local message =  string.format(L["开始ROLL"], LootItemLink )
    SendChatMessage(message, self.channelChat)
end
function MasterLootFrame:GetRandomCandidate(li)
    local ECNL,MN = self:GetECNL()
    local RCF = CreateFrame("frame")
    RCF:RegisterEvent("CHAT_MSG_SYSTEM")
    RCF:SetScript("OnEvent", function()
        local startRollIndex = string.find(arg1,"%d+")
        local _, endRollIndex = string.find(arg1, "%d+", startRollIndex)
        local roll = tonumber(string.sub(arg1, startRollIndex, endRollIndex))
        local wn = ECNL[roll]
        MasterLoot:LevelDebug(2, format("RR wn  got : <%s> ", tostring(wn)))
        if li then MasterLootFrame:GLTC(L["随机分配获胜"], wn,nil, nil, li)
        else
            MasterLootFrame:GLTC(L["随机分配获胜"], wn)
        end
        this:UnregisterAllEvents()
        lastRRtime = GetTime()
    end )
    if GetTime() - self.lastRRtime < 1 then return end
    RandomRoll(1, MN)
    self.lastRRtime = GetTime()
end

-- get uniteIndex like raid..i --
function MasterLootFrame:GetRI(name)
    self.prefix =  self.isRaid  and "raid" or "party"
    if self.playerName == name then return "player" end
    local NumGroupMembers = self.isRaid and 40 or 4
    for i = 1, NumGroupMembers do
        if name == UnitName(self.prefix..i) then
            return self.prefix..i
        end
    end
    return nil
end
-- get MasterLootCandidateIndex --
function MasterLootFrame:GetMLCI(name)
    for i = 1, 40 do
        local MLCName = GetMasterLootCandidate(i)
        if MLCName and MLCName == name then
            return i
        end
    end
    return nil
end
-- GetEligibleCandidateNameList --
function MasterLootFrame:GetECNL()
    local ECNL = {} --EligibleCandidateNameList
    local NumGroupMembers = self.isRaid and 40 or 4
    local count = 0
    for i = 1, NumGroupMembers do
        local MLCName = GetMasterLootCandidate(i)
        if MLCName then
            table.insert(ECNL, MLCName)
            count = count +1
        end
    end
    -- add player name if in party
    if not self.isRaid then
        if not tContains(ECNL, self.playerName) then
            table.insert(ECNL, self.playerName)
            count = count +1
        end
    end
    return ECNL, count
end
-- ReformEligibleCandidateNameListByClass --
function MasterLootFrame:ReformECNLBC(CandidateNameList)
    local CON = {} --ClassOnName
    local ECNLBC = {}  --EligibleCandidateNameListByClass
    local NumGroupMembers = self.isRaid and 40 or 4
    MasterLoot:LevelDebug(2, format("NumGroupMembers is <%s>. ", tostring(NumGroupMembers)))
    for i = 1, NumGroupMembers do
        local  RRName, _, _, _, RRClass, RRFileName

        if self.isRaid then
            RRName, _, _, _, RRClass, RRFileName, _, _ = GetRaidRosterInfo(i)
        else
            RRName = UnitName(self.prefix..i)
            RRClass, RRFileName = UnitClass(self.prefix..i)
        end

        if RRName then
            MasterLoot:LevelDebug(2, format("RRName is <%s>. RRfileName is <%s>. RRclass is <%s>", tostring(RRName), tostring(RRFileName), tostring(RRClass)))
            CON[RRName] = { RRFileName, RRClass }
        end
        end
     --ADD player if is in party
    if not self.isRaid then
        CON[self.playerName] = {self.playerFileName, self.playerClass}

    end
    for _, cn in ipairs(CandidateNameList) do
        if CON[cn] then
            local cfn = CON[cn][1] --CandidateFileName
            local cc = CON[cn][2]  --CandidateClass
            --MasterLoot:LevelDebug(2, format("Reform ECNLBC CandidateName is <%s>. ", tostring(i)))
            --MasterLoot:LevelDebug(2, format("Reform ECNLBC CandidateName is <%s>. ", tostring(cn)))
            --MasterLoot:LevelDebug(2, format("Reform ECNLBC CandidateFileName is <%s>. ", tostring(cfn)))
            --MasterLoot:LevelDebug(2, format("Reform ECNLBC CandidateClass is <%s>. ", tostring(cc)))
            if not ECNLBC[cfn] then
                ECNLBC[cfn] = {}
            end
            table.insert(ECNLBC[cfn],  {cn, cc, cfn})
        end
    end
    return ECNLBC, CON
end
-- GiveLootToCandidate GiveLootToCandidate --
function MasterLootFrame:GLTC(mode, CandidateName, ColorfulName, ColorfulClassName, LootIndex)
    --targetRosterIndex
    local ss = LootIndex and LootIndex or LootFrame.selectedSlot
    local _, _, quantity, quality = GetLootSlotInfo(ss)
    local link = GetLootSlotLink(ss)
    local message

    if mode==L["偷偷分给"] then GiveMasterLoot(ss, self:GetMLCI(CandidateName)) return end

    if not ColorfulName or not ColorfulClassName then
        message = MasterLoot:BuildMessage(
                string.format(tostring(mode),
                        tostring(CandidateName),
                        tostring(link),
                        tostring( quantity)
                )
        )
    else
        message = MasterLoot:BuildMessage(
                string.format(tostring(mode),
                        tostring(ColorfulClassName),
                        tostring(ColorfulName),
                        tostring(link),
                        tostring( quantity)
                )
        )
    end
    if quality > MasterLoot.opt.ItemQuality then
        SendChatMessage(message, self.channelChat)
    end
    local MLCI = self:GetMLCI(CandidateName)
    if MLCI then
        GiveMasterLoot(ss, MLCI)
    else
        SendChatMessage(MasterLoot:BuildMessage(L["无法分配"]), self.channelChat)
    end


    end
----------------------------------------------------------------------
---------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
--function MasterLootFrame:AutoFunction()
--    for li = 1, GetNumLootItems() do
--        local _, name, quantity, quality = GetLootSlotInfo(li)
--        local UnitMLCIndec = GetMasterLootCandidateIndex(self.playerName)
--
--        if  quantity ~=0  then
--            MasterLoot:LevelDebug(2,
--                    format("GetLootSlotInfo: <%s // %s // %s>",
--                            tostring(name), tostring(quantity), tostring(quality)))
--            if  quality <= 1 then
--                if MasterLoot.opt.AutoLoot then
--                    self:GLTC(L["偷偷分给"],nil, UnitMLCIndec,nil,nil,li)
--                elseif MasterLoot.opt.AutoRR then
--                    self:GetEligibleCandidateIndexList()
--                    self:GiveLootToRandomCandidate(li)
--                end
--            end
--        end
--    end
--end