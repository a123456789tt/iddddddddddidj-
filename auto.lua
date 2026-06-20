-- Вставляем в ваш код после Rivals блока

elseif selectedOption == "MyScript" then
    -- Устанавливаем переменные для автозагрузки
    getgenv().autoload = autoloadEnabled
    getgenv().silentload = silentloadEnabled
    getgenv().SCRIPT_KEY = ""
    
    -- Загружаем скрипт
    loadstring(game:HttpGet("https://raw.githubusercontent.com/a123456789tt/egegegegeg/refs/heads/main/farm.lua"))()
end
