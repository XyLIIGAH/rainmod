# Rainmod - аддон, способный буквально задавить своей тяжестью 

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c385a284-3b67-446d-99d3-6403a009b9c7" />



**Rainmod позволяет вызывать дождь из пропов, что может стать своеобразным испытанием для игрока.** 

**Аддон имеет два режима - *классический* и *sd-режим*.**

# Команды 

**Для старта *классического дождя* следует использовать команду**

```start_proprain arg1 arg2```

**arg1 - число секунд длительности дождя, а arg2 - интенсивность дождя.**

**Для старта *sd-дождя* следует использовать команду**

```start_sd arg1 arg2```

**arg1 - число секунд длительности дождя, а arg2 - интенсивность дождя.**

**Для очистки выпавших после дождя пропов следует использовать команду**

```clear_proprain```

**Для принудительной остановки *любого* дождя следует использовать команду**

```stop_proprain``` или ```stop_sd```, хотя функционал одинаковый(автору было лень удалять вторую команду)

# Особенности 

**По истечении времени все пропы, находящиеся близко к земле, фризятся, а те, что не успели приблизиться к земле - удаляются.**

**Список пропов того или иного дождя может быть изменен вами вручную, достаточно добавить свою модель в списки, как это сделал автор:**
```
    -- Список моделей пропов для спавна start_proprain
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
        "models/props_phx/misc/potato_launcher_explosive.mdl", -- Что-то взрывоопасное
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
```
**Have fun!**
