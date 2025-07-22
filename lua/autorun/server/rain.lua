if SERVER then
    AddCSLuaFile()

    -- Список моделей пропов для спавна, включая взрывоопасные и новые объекты
    local propModels = {
        "models/props_junk/wood_crate001a.mdl", -- Деревянный ящик
        "models/props_junk/metal_paintcan001a.mdl", -- Банка краски
        "models/props_junk/cardboard_box001a.mdl", -- Картонная коробка
        "models/props_c17/oildrum001.mdl", -- Бочка
        "models/props_junk/trafficcone001a.mdl", -- Дорожный конус
        "models/props_junk/propane_tank001a.mdl", -- Пропановый баллон
        "models/props_c17/canister02a.mdl", -- Канистра
        "models/props_junk/gascan001a.mdl", -- Бензиновая канистра
        "models/props_c17/oildrum001_explosive.mdl", -- Взрывоопасная бочка
        "models/props_phx/misc/potato_launcher_explosive.mdl", -- Взрывоопасный объект
        "models/props_junk/CinderBlock01a.mdl", -- Кирпич/бетонный блок
        "models/props_c17/tv_monitor01.mdl", -- Телевизор
        "models/props_lab/monitor02.mdl", -- Компьютерный монитор
        "models/props_junk/trashbin01a.mdl", -- Мусорный бак
        "models/nova/chair_office01.mdl", -- Стул
        "models/props_junk/watermelon01.mdl", -- Арбуз
        "models/props_lab/cactus.mdl", -- Кактус
        "models/props_junk/wood_pallet001a.mdl", -- Деревянный поддон
        "models/props_wasteland/prison_toilet01.mdl" -- Унитаз
    }

    -- Список моделей машин для команды start_sd
    local carPropModels = {
        "models/props_vehicles/car001a_hatchback.mdl", -- Хэтчбек
        "models/props_vehicles/car001b_hatchback.mdl", -- Хэтчбек (вариант)
        "models/props_vehicles/car002a.mdl", -- Седан
        "models/props_vehicles/car003a.mdl", -- Купе
        "models/props_vehicles/car004a.mdl", -- Пикап
        "models/props_vehicles/car005a.mdl", -- Спорткар
        "models/props_vehicles/van001a.mdl", -- Фургон
        "models/props_vehicles/truck001a.mdl", -- Грузовик
        "models/props_vehicles/truck002a_cab.mdl", -- Кабина грузовика
        "models/props_vehicles/apc001.mdl" -- Бронированная машина
    }

    -- Функция для обработки пропов дождя: замораживает упавшие и удаляет те, что в воздухе
    local function FreezeRainProps()
        local frozenCount = 0
        local removedCount = 0
        for _, ent in ipairs(ents.GetAll()) do
            if ent.IsPropRain then
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    local velocity = phys:GetVelocity()
                    local pos = ent:GetPos()
                    local trace = util.QuickTrace(pos, Vector(0, 0, -10000), ent)
                    local heightAboveGround = pos.z - trace.HitPos.z

                    -- Проверяем, находится ли проп в воздухе (высокая скорость вниз или большая высота)
                    if velocity.z < -100 or heightAboveGround > 100 then
                        ent:Remove()
                        removedCount = removedCount + 1
                    else
                        phys:EnableMotion(false) -- Замораживаем проп
                        phys:Sleep() -- Устанавливаем физический объект в спящий режим
                        frozenCount = frozenCount + 1
                    end
                end
            end
        end
        return frozenCount, removedCount
    end

    -- Консольная команда для запуска дождя из пропов
    concommand.Add("start_proprain", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("Только админы могут использовать эту команду!")
            end
            return
        end

        local duration = tonumber(args[1]) or 30 -- Длительность в секундах, 0 для бесконечного
        local intensity = tonumber(args[2]) or 10 -- Количество пропов в секунду

        if duration == 0 then
            ply:ChatPrint("Запущен бесконечный дождь из пропов с интенсивностью " .. intensity)
        else
            ply:ChatPrint("Запущен дождь из пропов на " .. duration .. " секунд с интенсивностью " .. intensity)
        end

        -- Удаляем существующий таймер, если он есть
        timer.Remove("PropRainTimer")

        -- Создаем таймер для спавна пропов
        timer.Create("PropRainTimer", 1 / intensity, duration == 0 and 0 or duration * intensity, function()
            if not IsValid(ply) and duration ~= 0 then
                timer.Remove("PropRainTimer")
                return
            end

            -- Получаем позицию над игроками
            local players = player.GetAll()
            if #players == 0 then return end

            for i = 1, math.random(1, 3) do -- Спавним 1-3 пропа за раз
                local randomPlayer = players[math.random(1, #players)]
                local spawnPos = randomPlayer:GetPos() + Vector(math.random(-500, 500), math.random(-500, 500), 2000)

                -- Создаем проп
                local prop = ents.Create("prop_physics")
                if not IsValid(prop) then return end

                prop:SetModel(propModels[math.random(1, #propModels)])
                prop:SetPos(spawnPos)
                prop:Spawn()

                -- Устанавливаем физику и суперпрыгучесть
                local phys = prop:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetMaterial("bouncy_metal") -- Высокая прыгучесть
                    phys:SetVelocity(Vector(0, 0, -500)) -- Начальная скорость вниз
                end

                -- Пометим проп как часть дождя для последующей очистки
                prop.IsPropRain = true
            end
        end)

        -- Останавливаем дождь после окончания длительности, если не бесконечный
        if duration >0 then
            timer.Simple(duration, function()
                timer.Remove("PropRainTimer")
                if IsValid(ply) then
                    local frozenCount, removedCount = FreezeRainProps()
                    ply:ChatPrint("Дождь из пропов окончен! Заморожено " .. frozenCount .. " пропов, удалено " .. removedCount .. " пропов в воздухе.")
                else
                    FreezeRainProps()
                end
            end)
        end
    end)

    -- Консольная команда для запуска дождя из машин (start_sd)
    concommand.Add("start_sd", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("Только админы могут использовать эту команду!")
            end
            return
        end

        local duration = tonumber(args[1]) or 30 -- Длительность в секундах, 0 для бесконечного
        local intensity = tonumber(args[2]) or 5 -- Количество машин в секунду (меньше, так как машины тяжелее)

        intensity = math.max(1, math.min(intensity, 10)) -- Ограничиваем интенсивность для машин

        if duration == 0 then
            ply:ChatPrint("Запущен бесконечный дождь из машин с интенсивностью " .. intensity)
        else
            ply:ChatPrint("Запущен дождь из машин на " .. duration .. " секунд с интенсивностью " .. intensity)
        end

        -- Удаляем существующий таймер для машин, если он есть
        timer.Remove("CarRainTimer")

        -- Создаем таймер для спавна машин
        timer.Create("CarRainTimer", 1 / intensity, duration == 0 and 0 or duration * intensity, function()
            if not IsValid(ply) and duration ~= 0 then
                timer.Remove("CarRainTimer")
                return
            end

            -- Получаем позицию над игроками
            local players = player.GetAll()
            if #players == 0 then return end

            for i = 1, math.random(1, 2) do -- Спавним 1-2 машины за раз
                local randomPlayer = players[math.random(1, #players)]
                local spawnPos = randomPlayer:GetPos() + Vector(math.random(-500, 500), math.random(-500, 500), 2000)

                -- Создаем проп машины
                local prop = ents.Create("prop_physics")
                if not IsValid(prop) then return end

                prop:SetModel(carPropModels[math.random(1, #carPropModels)])
                prop:SetPos(spawnPos)
                prop:Spawn()

                -- Устанавливаем физику
                local phys = prop:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetMaterial("bouncy_metal") -- Прыгучесть для эффекта
                    phys:SetVelocity(Vector(0, 0, -500)) -- Начальная скорость вниз
                end

                -- Пометим проп как часть дождя для последующей очистки
                prop.IsPropRain = true
            end
        end)

        -- Останавливаем дождь после окончания длительности, если не бесконечный
        if duration > 0 then
            timer.Simple(duration, function()
                timer.Remove("CarRainTimer")
                if IsValid(ply) then
                    local frozenCount, removedCount = FreezeRainProps()
                    ply:ChatPrint("Дождь из машин окончен! Заморожено " .. frozenCount .. " машин, удалено " .. removedCount .. " машин в воздухе.")
                else
                    FreezeRainProps()
                end
            end)
        end
    end)

    -- Команда для остановки дождя из пропов
    concommand.Add("stop_proprain", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("Только админы могут использовать эту команду!")
            end
            return
        end

        timer.Remove("PropRainTimer")
        timer.Remove("CarRainTimer")
        local frozenCount, removedCount = FreezeRainProps()
        ply:ChatPrint("Дождь из пропов и машин принудительно остановлен! Заморожено " .. frozenCount .. " пропов и машин, удалено " .. removedCount .. " в воздухе.")
    end)

    -- Команда для остановки дождя из машин
    concommand.Add("stop_sd", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("Только админы могут использовать эту команду!")
            end
            return
        end

        timer.Remove("CarRainTimer")
        local frozenCount, removedCount = FreezeRainProps()
        ply:ChatPrint("Дождь из машин принудительно остановлен! Заморожено " .. frozenCount .. " машин, удалено " .. removedCount .. " в воздухе.")
    end)

    -- Команда для очистки всех пропов дождя
    concommand.Add("clear_proprain", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("Только админы могут использовать эту команду!")
            end
            return
        end

        local count = 0
        for _, ent in ipairs(ents.GetAll()) do
            if ent.IsPropRain then
                ent:Remove()
                count = count + 1
            end
        end

        ply:ChatPrint("Удалено " .. count .. " пропов и машин из дождя!")
    end)
end