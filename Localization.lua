local ADDON, NS = ...

local locale = GetLocale and GetLocale() or "enUS"
local zh = (locale == "zhCN" or locale == "zhTW")

local L = {}
NS.L = L

if zh then
    L.TITLE = "灵魂碎片管家"
    L.SUBTITLE = "SoulShardKeeper · 魔兽世界：无限 1.60"

    L.AUTO_SECTION = "自动销毁"
    L.AUTO_ENABLE = "启用自动销毁"
    L.AUTO_DESC = "背包中的灵魂碎片超过上限时，在你按键或点击世界时自动销毁 1 个，直到降到上限。"
    L.CAP_LABEL = "保留上限"
    L.CAP_ZERO_NOTE = "设为 0 时会销毁所有灵魂碎片。"
    L.CHAT_CHECK = "每次销毁时在聊天框提示"
    L.GLINT_CHECK = "销毁时静音宝石拾取/放下音效"

    L.BUTTON_SECTION = "悬浮球"
    L.SHOW_CHECK = "显示悬浮球"
    L.LOCK_CHECK = "锁定位置"
    L.SCALE_LABEL = "大小"
    L.RESET_BUTTON = "重置位置"
    L.DESTROY_BUTTON = "立即销毁 1 个"

    L.STATUS_SECTION = "状态"
    L.CURRENT_LINE = "背包内灵魂碎片：%d 个"
    L.EXCESS_LINE = "超出上限：%d 个"
    L.STATUS_OFF = "自动销毁已关闭"
    L.STATUS_COMBAT = "战斗中暂停，脱战后继续"
    L.STATUS_CURSOR = "光标上有物品，暂不处理"
    L.STATUS_WAITING = "待清理 %d 个 · 按任意键或点击世界"
    L.STATUS_WITHIN = "已在上限内"

    L.FOOTER = "左键：销毁 1 个   ·   右键：设置   ·   拖动：移动"
    L.CMD_FOOTER = "命令：/ssk   ·   /ssk cap 10   ·   /ssk hide"

    L.TIP_COUNT = "背包内灵魂碎片"
    L.TIP_CAP = "保留上限"
    L.TIP_LEFT = "左键：销毁 1 个"
    L.TIP_RIGHT = "右键：打开设置"
    L.TIP_DRAG = "拖动：移动位置"
    L.TIP_LOCKED = "位置已锁定（设置中可解锁）"
    L.TIP_STATUS = "状态"

    L.MSG_WELCOME = "已加载。左键销毁 1 个，右键打开设置。输入 /ssk 查看命令。"
    L.MSG_ONLY_WARLOCK = "此插件仅对术士角色生效。"
    L.MSG_NO_SHARDS = "背包中没有灵魂碎片。"
    L.MSG_COMBAT = "战斗中无法销毁物品。"
    L.MSG_CURSOR = "光标上有物品，请先放下后再试。"
    L.MSG_LOCKED = "找不到可销毁的灵魂碎片（可能被锁定）。"
    L.MSG_FAILED = "销毁失败：客户端要求确认，或物品被锁定。"
    L.MSG_DELETED = "已销毁 1 个灵魂碎片（%d → %d，上限 %d）。"
    L.MSG_EXCEED = "灵魂碎片超出上限 %d 个，将在你下次按键或点击世界时自动清理。"
    L.MSG_CAP_SET = "保留上限已设为 %d 个。"
    L.MSG_AUTO_ON = "自动销毁已开启。"
    L.MSG_AUTO_OFF = "自动销毁已关闭。"
    L.MSG_HIDDEN = "悬浮球已隐藏，输入 /ssk show 恢复。"
    L.MSG_SHOWN = "悬浮球已显示。"
    L.MSG_LOCKED_POS = "位置已锁定。"
    L.MSG_UNLOCKED_POS = "位置已解锁，可以拖动。"
    L.MSG_RESET = "悬浮球位置和大小已重置。"
    L.MSG_STATUS = "当前 %d 个 / 上限 %d 个 / 自动：%s / 状态：%s"
    L.MSG_BAD_CAP = "请输入 0 到 100 之间的数字，例如：/ssk cap 10"
    L.MSG_NO_UI = "界面尚未准备好，请稍后再试。"
    L.ON = "开"
    L.OFF = "关"

    L.HELP_HEADER = "命令："
    L.HELP_LINES = {
        "/ssk            打开设置",
        "/ssk show       显示悬浮球",
        "/ssk hide       隐藏悬浮球",
        "/ssk lock       锁定位置",
        "/ssk unlock     解锁位置",
        "/ssk cap 10     保留最多 10 个灵魂碎片",
        "/ssk on / off   开启 / 关闭自动销毁",
        "/ssk status     查看当前数量与状态",
        "/ssk reset      重置悬浮球位置和大小",
    }
else
    L.TITLE = "SoulShardKeeper"
    L.SUBTITLE = "SoulShardKeeper · WoW Forever 1.60"

    L.AUTO_SECTION = "Automatic destruction"
    L.AUTO_ENABLE = "Enable automatic destruction"
    L.AUTO_DESC = "When you carry more Soul Shards than the cap, one is destroyed on your next key press or world click until you are back at the cap."
    L.CAP_LABEL = "Keep at most"
    L.CAP_ZERO_NOTE = "Setting this to 0 destroys every Soul Shard."
    L.CHAT_CHECK = "Print a chat message for each destroyed shard"
    L.GLINT_CHECK = "Mute the gem pick-up / put-down sound while deleting"

    L.BUTTON_SECTION = "Orb"
    L.SHOW_CHECK = "Show the orb"
    L.LOCK_CHECK = "Lock position"
    L.SCALE_LABEL = "Size"
    L.RESET_BUTTON = "Reset position"
    L.DESTROY_BUTTON = "Destroy 1 now"

    L.STATUS_SECTION = "Status"
    L.CURRENT_LINE = "Soul Shards carried: %d"
    L.EXCESS_LINE = "Above the cap: %d"
    L.STATUS_OFF = "Automatic destruction is off"
    L.STATUS_COMBAT = "Paused in combat; resumes afterwards"
    L.STATUS_CURSOR = "An item is on your cursor"
    L.STATUS_WAITING = "%d to clean up · press a key or click the world"
    L.STATUS_WITHIN = "Within the cap"

    L.FOOTER = "Left click: destroy 1   ·   Right click: settings   ·   Drag: move"
    L.CMD_FOOTER = "Commands: /ssk   ·   /ssk cap 10   ·   /ssk hide"

    L.TIP_COUNT = "Soul Shards carried"
    L.TIP_CAP = "Cap"
    L.TIP_LEFT = "Left click: destroy 1"
    L.TIP_RIGHT = "Right click: open settings"
    L.TIP_DRAG = "Drag: move the orb"
    L.TIP_LOCKED = "Position locked (unlock in settings)"
    L.TIP_STATUS = "Status"

    L.MSG_WELCOME = "loaded. Left click destroys 1, right click opens settings. Type /ssk for commands."
    L.MSG_ONLY_WARLOCK = "This addon only works on Warlocks."
    L.MSG_NO_SHARDS = "There are no Soul Shards in your bags."
    L.MSG_COMBAT = "Items cannot be destroyed in combat."
    L.MSG_CURSOR = "An item is on your cursor. Put it down first."
    L.MSG_LOCKED = "No destroyable Soul Shard found (it may be locked)."
    L.MSG_FAILED = "Destroy failed: the client asked for confirmation, or the item is locked."
    L.MSG_DELETED = "Destroyed 1 Soul Shard (%d -> %d, cap %d)."
    L.MSG_EXCEED = "You are %d Soul Shard(s) above the cap. Extras will be cleaned up on your next key press or world click."
    L.MSG_CAP_SET = "Cap set to %d."
    L.MSG_AUTO_ON = "Automatic destruction is on."
    L.MSG_AUTO_OFF = "Automatic destruction is off."
    L.MSG_HIDDEN = "Orb hidden. Type /ssk show to bring it back."
    L.MSG_SHOWN = "Orb shown."
    L.MSG_LOCKED_POS = "Position locked."
    L.MSG_UNLOCKED_POS = "Position unlocked; you can drag the orb."
    L.MSG_RESET = "Orb position and size reset."
    L.MSG_STATUS = "Carried %d / cap %d / auto: %s / status: %s"
    L.MSG_BAD_CAP = "Enter a number from 0 to 100, for example: /ssk cap 10"
    L.MSG_NO_UI = "The interface is not ready yet. Try again in a moment."
    L.ON = "on"
    L.OFF = "off"

    L.HELP_HEADER = "Commands:"
    L.HELP_LINES = {
        "/ssk            open settings",
        "/ssk show       show the orb",
        "/ssk hide       hide the orb",
        "/ssk lock       lock the position",
        "/ssk unlock     unlock the position",
        "/ssk cap 10     keep at most 10 Soul Shards",
        "/ssk on / off   enable / disable automatic destruction",
        "/ssk status     show the current count and state",
        "/ssk reset      reset the orb position and size",
    }
end
