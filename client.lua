---@type table
local Config = lib.load('config')
---@type table
local printers = {}
---@type any
local prop = nil
lib.locale()

---@param data table
---@param item table
local usePrinter = function(data, item)
    textUI(locale('textui_place'))
    lib.callback.await('mt_printers:server:itemActions', false, item.name, 'remove')
    local prop = CreateObject(GetHashKey(Config.printers[item.name]), 0, 0, 0, false, false, false)
    local heading = GetEntityHeading(prop)
    SetEntityAlpha(prop, 150, false)
    SetEntityCollision(prop, false, false)

    CreateThread(function()
        while true do
            Wait(0)
            local coords = rayCastGamePlayCamera(4.0)
            SetEntityCoords(prop, coords.x, coords.y, coords.z, heading, false, false, false)
            PlaceObjectOnGroundProperly(prop)

            if IsControlPressed(0, 15) then
                heading += 1.0
                SetEntityHeading(prop, heading)
            elseif IsControlPressed(0, 14) then
                heading -= 1.0
                SetEntityHeading(prop, heading)
            end

            if IsControlPressed(0, 176) then
                DeleteObject(prop)
                DeleteEntity(prop)
                hideTextUI()
                lib.callback.await('mt_printers:server:place', false, item.name, coords, heading)
                break
            elseif IsControlPressed(0, 177) then
                DeleteObject(prop)
                DeleteEntity(prop)
                hideTextUI()
                lib.callback.await('mt_printers:server:itemActions', false, item.name, 'add')
                break
            end
        end
    end)
end
exports('usePrinter', usePrinter)

---@param data table
---@param item table
local useDocument = function(data, item)
    SendNUIMessage({ action = 'show', image_url = item.metadata.imageurl })
end
exports('useDocument', useDocument)

local openPrinter = function()
    local input = lib.inputDialog(locale('printer'), {
        { type = 'input', placeholder = locale('image_placeholder'), label = locale('image_name'), required = true },
        { type = 'input', placeholder = locale('image_url'), description = locale('img_link'), label = locale('img_to_print'), required = true },
        { type = 'slider', max = 10, min = 1, default = 1, label = locale('quantity'), required = true },
    })
    if input then
        if not input[1] or not input[2] or not input[3] then return end
        if not input[2]:match(locale('input_url_match')) then notify(locale('notify_wrong_url'), 'error') return end
        if exports.ox_inventory:GetItemCount('printer_paper') < input[3] then notify(locale('notify_no_paper'), 'error') return end
        if lib.progressBar({ label = locale('print_progress'), duration = 5000 }) then
            lib.callback.await('mt_printers:server:printDocument', false, input)
        end
    end
end

---@param id number
---@param item string
local deletePrinter = function(id, item)
    lib.callback.await('mt_printers:server:delete', false, id)
    lib.callback.await('mt_printers:server:itemActions', false, item, 'add')
end

local spawnAllPrinters = function()
    local svPrinters = lib.callback.await('mt_printers:server:getPrinters')
    for k, v in pairs(svPrinters) do
        if printers[v.id] then goto continue end

        local prop = CreateObject(GetHashKey(Config.printers[v.printer]), v.coords.x, v.coords.y, v.coords.z, false, false, false)
        SetEntityHeading(prop, v.coords.w)
        PlaceObjectOnGroundProperly(prop)
        Wait(200)
        FreezeEntityPosition(prop, true)

        printers[k] = v
        printers[k].prop = prop

        exports.ox_target:addLocalEntity(prop, {
            {
                label = locale('target_use'),
                icon = 'fas fa-print',
                onSelect = openPrinter
            },
            {
                label = locale('target_pick'),
                icon = 'fas fa-hand-paper',
                onSelect = function()
                    deletePrinter(k, v.printer)
                end
            }
        })

        :: continue ::
    end
end

local despawnAllPrinters = function()
    for _, v in pairs(printers) do
        DeleteObject(v.prop)
        DeleteEntity(v.prop)
    end
    printers = {}
end

lib.callback.register('mt_printers:client:updatePrinters', function()
    spawnAllPrinters()
end)

lib.callback.register('mt_printers:client:delete', function(id)
    if printers[id] then
        DeleteObject(printers[id].prop)
        DeleteEntity(printers[id].prop)
        printers[id] = nil
    end
end)


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(500)
    spawnAllPrinters()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    despawnAllPrinters()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(500)
    spawnAllPrinters()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    despawnAllPrinters()
end)

RegisterNUICallback('setUIFocus', function()
    SetNuiFocus(true, true)
    loadAnimDict('missfam4')
    TaskPlayAnim(cache.ped, 'missfam4', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    loadModel('p_amb_clipboard_01')
    prop = CreateObject(GetHashKey('p_amb_clipboard_01'), 0.0, 0.0, 0.0, true, false, false)
    AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 36029), 0.16, 0.08, 0.1, -130.0, -50.0, 0.0, false, true, false, false, true, true)
end)

RegisterNUICallback('unsetUIFocus', function()
    SetNuiFocus(false, false)
    ClearPedTasks(cache.ped)
    StopAnimTask(cache.ped, 'missfam4', 'base', 0.0)
    RemoveAnimDict('missfam4')
    DeleteEntity(prop)
end)
