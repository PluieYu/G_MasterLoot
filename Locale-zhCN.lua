
local L = AceLibrary("AceLocale-2.2"):new("MasterLoot")
L:RegisterTranslations("zhCN", function() return {
	["小皮箱队团队助手"] = "|cffF5F54A[小皮箱]|r|cff9482C9团队助手|r",
	["已加载"] ="已加载",
	["已开启"] ="已开启",
	["已关闭"] ="已关闭",
	["已重置"] ="已重置",
	["已删除"] =  "已删除",
	["已存在"] = "已存在",
	["已添加"] = "已添加",
	["移除"] ="移除",
	["关闭"] =  "关闭",
	["清空列表"] = "清空列表",

	["额外拾取模式"] ="额外拾取模式",
	["额外拾取模式描述"] ="选择额外的拾取模式",

	["通通归我"]="通通归我",
	["通通归我描述"]="打开/关闭 选定等级物品都是我的",

	["见者有份"]="见者有份",
	["见者有份描述"]="打开/关闭 选定等级物品随机分配",

	["选定物品等级"] = "选定物品等级",
	["选定物品等级描述"] ="选定物品等级应用到 通通归我 或者 见者有份模式",



	--值钱的物品--
	["值钱的归我"] = "值钱的归我",
	["值钱的归我描述"] = "打开/关闭 垃圾装备无所谓 这里面值钱的东西都是我的",

	["值钱的物品"] = "值钱的物品",
	["清空值钱的物品列表描述"] = "清空值钱的物品列表",
	["值钱的物品描述"] = "管理值钱的物品列表",

	["添加物品"] = "添加到值钱的物品",
	["添加目标描述"] = "这个东西我要了 放进值钱的物品列表",
	["手动添加物品"] = "手动添加物品",
	["手动添加物品描述"] = "手动输入物品名字来添加到值钱的物品列表",
	["移除物品"] = "从值钱的物品中移除",
	["移除物品描述"] = "这个东西我不稀罕了 移出值钱的物品列表",

	--快捷分配--
	["快捷分配列表"] = "快捷分配",
	["快捷分配列表描述"] = "管理快捷分配玩家列表",
	["清空快捷分配列表描述"] = "清空快捷分配列表",
	["添加目标"] = "添加目标",
	["添加目标描述"] = "添加目标到快捷分配",
	["已添加到快捷分配列表"] = "已添加|cffF5F54A[%s]|r到快捷分配列表",
	["你必须有目标"] = "你必须有目标才能添加到快捷分配列表",
	["手动添加玩家"] = "添加玩家",
	["手动添加目标描述"]= "手动输入玩家名字来添加到快捷分配列表" ,


	["开始ROLL"] = "|cffF5F54A《|r%s|cffF5F54A》|r 许愿打|cffffffff[1]|r 需求打|cffffffff[2]|r 贪婪打|cffffffff[3]|r",
	["偷偷分给"] = "偷偷分给",
	["自己"] = "自己",
	["随机分配"] = "随机分配",
	["随机分配获胜"] = "随机分配 恭喜 |cffF5F54A[%s]|r 获得 %s*|cffF5F54A%s|r",
	["分给"] = "ROLL最高 恭喜 [%s]%s 获得 %s*|cffF5F54A%s|r",
	["没有拾取权"] = "没有拾取权",
	["无法分配"] = "错误 无法分配 %s 给|cffF5F54A[%s]|r 请确认目标是否有拾取权 否则请改自由拾取",
	font = "Fonts\\FRIZQT__.TTF"
} end)

