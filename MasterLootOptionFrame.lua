---
--- Documentation https://github.com/PluieYu/G_MasterLoot?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/23 21:25
---

local L = AceLibrary("AceLocale-2.2"):new("MasterLoot")
MasterLootOptionFrame = {}

function MasterLootOptionFrame:OnInitialize()
    self.EIL = AceLibrary("Dewdrop-2.0")     --ExtraItemList
    self.EPL = AceLibrary("Dewdrop-2.0")     --ExtraPlayerList
end
function MasterLootOptionFrame:SetupEILFrame()
    self.EIL:Open(
            UIParent,
            'children',
            function(level, value)
                self:CreateEILFrame(level, value)
            end,
            'cursorX', nil,
            'cursorY', true,
            'point',"CENTER",
            'relativePoint', "CENTER"
    )
end

function MasterLootOptionFrame:CreateEILFrame(level, value)
    if level == 1 then
        self.EIL:AddLine(
                'text', L["清空列表"] ,
                'tooltipText', L["清空值钱的物品列表描述"],
                'func', function()
                    MasterLoot:CleanExtraItemList()
                end)
        self.EIL:AddLine(
                'text', L["手动添加物品"],
                'tooltipText', L["手动添加物品描述"],
                'hasArrow', true,
                'hasEditBox', true,
                'editBoxText', nil,
                'editBoxFunc',
                function()
                    local itemName = this:GetText()
                    if tContainsKey(MasterLoot.opt.ReservedItemList, itemName) then
                        MasterLoot:Print(itemName..L["已存在"])
                    else
                        MasterLoot.opt.ReservedItemList[itemName] = 0
                        MasterLoot:Print(itemName..L["已添加"])
                    end
                end
                )
        for k, v in pairs(MasterLoot.opt.ReservedItemList) do
            if v==0 then
                self.EIL:AddLine(
                        'text',  k,
                        'hasArrow', true,
                        'value', k)
            else
                self.EIL:AddLine(
                        'text',  k,
                        'hasArrow', true,
                        'value', k,
                        'tooltipFunc', GameTooltip.SetHyperlink,
                        'tooltipArg1', GameTooltip,
                        'tooltipArg2', v
                )
            end
        end
    elseif level == 2 then
        self.EIL:AddLine(
                'text', L["移除"],
                'closeWhenClicked', true,
                'func', function()
                    MasterLoot:RemoveExtraItem(value)
                end)

    end
end
function MasterLootOptionFrame:SetupEPLFrame()
    self.EPL:Open(
            UIParent,
            'children',
            function(level, value)
                self:CreateEPLFrame(level, value)
            end,
            'cursorX', nil,
            'cursorY', true,
            'point',"CENTER",
            'relativePoint', "CENTER"
    )
end
function MasterLootOptionFrame:CreateEPLFrame(level, value)
    if level == 1 then
        self.EPL:AddLine(
                'text', L["清空列表"] ,
                'tooltipText', L["清空快捷分配列表描述"],
                'func', function()
                    MasterLoot:CleanExtraPlayerList()
                end)
        self.EPL:AddLine(
                'text', L["添加目标"] ,
                'tooltipText', L["添加目标描述"],
                'func', function()
                    MasterLoot:AddTargetToExtraPlayerList()
                end)
        self.EPL:AddLine(
                'text', L["手动添加玩家"],
                'tooltipText', L["手动添加目标描述"],
                'hasArrow', true,
                'hasEditBox', true,
                'editBoxText', nil,
                'editBoxFunc',
                function()
                    local itemName = this:GetText()
                    if tContainsKey(MasterLoot.opt.ReservedPlayerList, itemName) then
                        MasterLoot:Print(itemName..L["已存在"])
                    else
                        MasterLoot.opt.ReservedPlayerList[itemName] = 0
                        MasterLoot:Print(itemName..L["已添加"])
                    end
                end
        )
        for i, _ in pairs(MasterLoot.opt.ReservedPlayerList) do
            local unite = MasterLootFrame:GetRI(i)
            if unite then
                self.EPL:AddLine(
                        'text', i,
                        'hasArrow', true,
                        'value', i
                )
            else
                self.EPL:AddLine(
                        'text', i,
                        'hasArrow', true,
                        'value', i,
                        'tooltipFunc', GameTooltip.SetUnit,
                        'tooltipArg1', GameTooltip ,
                        'tooltipArg2', unite
                )
            end
    end
    elseif level == 2 then
        self.EPL:AddLine(
                'text', L["移除"],
                'closeWhenClicked', true,
                'func', function()
                    MasterLoot:RemoveExtraPlayer(value)
                end)

    end
end