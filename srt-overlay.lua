-- re4r srt overlay

local ff, fw, fh

local function get_da()
    local z = sdk.get_managed_singleton("chainsaw.GameRankSystem")
    return tostring(z:call("get_GameRank"))
end

local function get_Points()
    local z = sdk.get_managed_singleton("chainsaw.GameRankSystem")
    local ap = FloatColumn(z:get_field("_ActionPoint"))
    local ip = FloatColumn(z:get_field("_ItemPoint"))
    -- get total points and remove decimals
    local total = math.floor(ap:get_value() + ip:get_value())
    da0Values={1999,2999,3999,4999,5999,6999,7999,8999,9999,10999}
    -- get the index of the closest value in the table
    local index = 1
    for i=1,#da0Values do
        if math.abs(total - da0Values[i]) < math.abs(total - da0Values[index]) then
            index = i
        end
    end
    closest = da0Values[index]
    -- get the difference between the closest value and the total
    local difference = total - closest
    -- create table of all relevant values to return
    local returnValues = {}
    returnValues["ap"] = ap:get_value()
    returnValues["ip"] = ip:get_value()
    returnValues["total"] = total
    returnValues["closest"] = closest
    returnValues["difference"] = difference
    return returnValues
end

local function get_killcount()
    local z = sdk.get_managed_singleton("chainsaw.GameStatsManager")
    return tostring(z:call("getKillCount"))
end

local function get_money()
    local z = sdk.get_managed_singleton("chainsaw.InventoryManager")
    z = tostring(z:call("get_CurrPTAS"))
    return z:reverse():gsub("...", "%1,", (#z - 1) // 3):reverse()
end

local function get_enemies()
    local z = sdk.get_managed_singleton("chainsaw.CharacterManager")
    local p = z:call("getPlayerContextRef")
    if p ~= nil then
        p = p:call("get_Position")
    end
    local a = z:call("get_EnemyContextList")
    local r = {}
    for i = 0, a:call("get_Count") - 1 do
        local x = a:call("get_Item", i)
        local h = x:call("get_HitPoint")
        local m = h:call("get_DefaultHitPoint")
        if m ~= 1 and h:call("get_IsLive") then
            table.insert(r, {
                h:call("get_CurrentDamagePoint"),
                m,
                (p - x:call("get_Position")):length(),
                h:call("get_CurrentHitPoint"),
                h:call("get_HitPointRatio")
            })
        end
    end
    table.sort(r, function(a, b)
        return a[1] > b[1] or (a[1] == b[1] and (a[2] > b[2] or
            (a[2] == b[2] and a[3] < b[3])))
    end)
    return r
end

d2d.register(function()
    ff = d2d.Font.new("Verdana", 24)
    _, fh = ff:measure("0123456789")
    fw = 0
    for i = 0, 9 do
        local x, _ = ff:measure(tostring(i))
        fw = math.max(fw, x)
    end
end, function()
    local sw, sh = d2d.surface_size()
    local x0 = 15
    local y1 = sh - 15
    local x1 = x0 + 14 * fw
    local y0 = y1 - 7 * fh
    d2d.fill_rect(x0, y0, x1 - x0 + 0.25 * fw, y1 - y0, 0x802e3440)

    local m = get_money()
    local w, _ = ff:measure(m)
    d2d.text(ff, "ptas", x0 + 0.5 * fw, y0, 0xffeceff4)
    d2d.text(ff, m, x1 - w, y0, 0xffeceff4)

    local da = "da " .. get_da()
    d2d.text(ff, da, x0 + 0.5 * fw, y0 + fh, 0xffeceff4)

    local pointsTable = get_Points()
    for i, v in pairs(pointsTable) do
        print(i .. ' ' .. v)
        d2d.text(ff, i .. ' ' .. v, x0 + 0.5 * fw, y0 + fh, 0xffeceff4)
    end

    local kc = get_killcount()
    w, _ = ff:measure(kc)
    d2d.text(ff, kc, x1 - w, y0 + fh, 0xffeceff4)
    kc = "kc"
    w, _ = ff:measure(kc)
    d2d.text(ff, kc, x1 - w - 3.5 * fw, y0 + fh, 0xffeceff4)

    for i, x in ipairs(get_enemies()) do
        if i <= 5 then
            local s = tostring(x[4])
            w, _ = ff:measure(s)
            d2d.text(ff, s, x1 - w, y0 + (1 + i) * fh, 0xffeceff4)
            local a0 = x0 + 0.5 * fw
            local b0 = y0 + (1.3 + i) * fh
            local a1 = x1 - x0 - 6 * fw
            local b1 = 0.4 * fh
            d2d.fill_rect(a0, b0, a1 * x[5], b1, 0xffa3be8c)
            d2d.outline_rect(a0, b0, a1, b1, 1, 0xff4c566a)
        end
    end
end)
