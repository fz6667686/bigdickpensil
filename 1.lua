-- Крестики-нолики (Tic-Tac-Toe) с ботом для Matcha LuaVM

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Игровое поле (3x3)
local board = {
    { "", "", "" },
    { "", "", "" },
    { "", "", "" }
}

local currentPlayer = "X"  -- X всегда ходит первым (игрок)
local gameOver = false
local winner = ""

-- Размеры и отступы
local cellSize = 100
local offsetX = 50
local offsetY = 50

-- Функция для очистки всех объектов рисования
local function clearDrawings()
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Remove") then
            pcall(obj.Remove, obj)
        end
    end
end

-- Функция для отрисовки поля
local function drawBoard()
    clearDrawings()

    -- Линии сетки
    for i = 1, 2 do
        local lineV = Drawing.new("Line")
        lineV.From = Vector2.new(offsetX + i * cellSize, offsetY)
        lineV.To = Vector2.new(offsetX + i * cellSize, offsetY + 3 * cellSize)
        lineV.Color = Color3.fromRGB(200, 200, 200)
        lineV.Thickness = 3
        lineV.Visible = true

        local lineH = Drawing.new("Line")
        lineH.From = Vector2.new(offsetX, offsetY + i * cellSize)
        lineH.To = Vector2.new(offsetX + 3 * cellSize, offsetY + i * cellSize)
        lineH.Color = Color3.fromRGB(200, 200, 200)
        lineH.Thickness = 3
        lineH.Visible = true
    end

    -- Фигуры (X и O)
    for row = 1, 3 do
        for col = 1, 3 do
            local val = board[row][col]
            if val == "X" then
                local x1 = offsetX + (col - 1) * cellSize + 15
                local y1 = offsetY + (row - 1) * cellSize + 15
                local x2 = offsetX + col * cellSize - 15
                local y2 = offsetY + row * cellSize - 15

                local line1 = Drawing.new("Line")
                line1.From = Vector2.new(x1, y1)
                line1.To = Vector2.new(x2, y2)
                line1.Color = Color3.fromRGB(255, 50, 50)
                line1.Thickness = 6
                line1.Visible = true

                local line2 = Drawing.new("Line")
                line2.From = Vector2.new(x2, y1)
                line2.To = Vector2.new(x1, y2)
                line2.Color = Color3.fromRGB(255, 50, 50)
                line2.Thickness = 6
                line2.Visible = true
            elseif val == "O" then
                local circle = Drawing.new("Circle")
                circle.Position = Vector2.new(
                    offsetX + (col - 1) * cellSize + cellSize / 2,
                    offsetY + (row - 1) * cellSize + cellSize / 2
                )
                circle.Radius = 35
                circle.Color = Color3.fromRGB(50, 150, 255)
                circle.Thickness = 6
                circle.Filled = false
                circle.Visible = true
            end
        end
    end

    -- Сообщение о победителе / ничьей
    if gameOver then
        local msg = Drawing.new("Text")
        msg.Text = winner ~= "" and ("Победил " .. winner .. "!") or "Ничья!"
        msg.Position = Vector2.new(offsetX + 3 * cellSize / 2, offsetY + 3 * cellSize + 30)
        msg.Color = Color3.fromRGB(255, 255, 255)
        msg.FontSize = 28
        msg.Font = Drawing.Fonts.Monospace
        msg.Center = true
        msg.Visible = true

        -- Кнопка "Новая игра"
        local btn = Drawing.new("Square")
        btn.Position = Vector2.new(offsetX + 3 * cellSize / 2 - 70, offsetY + 3 * cellSize + 70)
        btn.Size = Vector2.new(140, 40)
        btn.Color = Color3.fromRGB(50, 200, 50)
        btn.Filled = true
        btn.Visible = true
        btn.ZIndex = 2

        local btnText = Drawing.new("Text")
        btnText.Text = "Новая игра"
        btnText.Position = Vector2.new(offsetX + 3 * cellSize / 2, offsetY + 3 * cellSize + 90)
        btnText.Color = Color3.fromRGB(0, 0, 0)
        btnText.FontSize = 18
        btnText.Font = Drawing.Fonts.Monospace
        btnText.Center = true
        btnText.Visible = true
        btnText.ZIndex = 3
    end
end

-- Проверка победителя
local function checkWinner()
    local lines = {
        -- строки
        {{1,1},{1,2},{1,3}},
        {{2,1},{2,2},{2,3}},
        {{3,1},{3,2},{3,3}},
        -- столбцы
        {{1,1},{2,1},{3,1}},
        {{1,2},{2,2},{3,2}},
        {{1,3},{2,3},{3,3}},
        -- диагонали
        {{1,1},{2,2},{3,3}},
        {{1,3},{2,2},{3,1}}
    }

    for _, line in ipairs(lines) do
        local a = board[line[1][1]][line[1][2]]
        local b = board[line[2][1]][line[2][2]]
        local c = board[line[3][1]][line[3][2]]
        if a ~= "" and a == b and b == c then
            return a
        end
    end

    -- Проверка ничьей
    local empty = 0
    for row = 1, 3 do
        for col = 1, 3 do
            if board[row][col] == "" then
                empty = empty + 1
            end
        end
    end
    if empty == 0 then
        return "draw"
    end

    return nil
end

-- Ход бота (простой: выбирает первую пустую клетку)
local function botMove()
    if gameOver then return end
    if currentPlayer ~= "O" then return end

    -- Поиск пустой клетки
    for row = 1, 3 do
        for col = 1, 3 do
            if board[row][col] == "" then
                board[row][col] = "O"
                currentPlayer = "X"

                local result = checkWinner()
                if result then
                    gameOver = true
                    if result == "draw" then
                        winner = ""
                    else
                        winner = result
                    end
                end

                drawBoard()
                return
            end
        end
    end
end

-- Обработка клика мыши
mouse.Button1Down:Connect(function()
    if gameOver then
        -- Проверка клика по кнопке "Новая игра"
        local mx = mouse.X
        local my = mouse.Y
        local btnX = offsetX + 3 * cellSize / 2 - 70
        local btnY = offsetY + 3 * cellSize + 70
        if mx >= btnX and mx <= btnX + 140 and my >= btnY and my <= btnY + 40 then
            -- Сброс игры
            board = {
                { "", "", "" },
                { "", "", "" },
                { "", "", "" }
            }
            currentPlayer = "X"
            gameOver = false
            winner = ""
            drawBoard()
        end
        return
    end

    if currentPlayer ~= "X" then return end

    -- Определение клетки по координатам мыши
    local col = math.floor((mouse.X - offsetX) / cellSize) + 1
    local row = math.floor((mouse.Y - offsetY) / cellSize) + 1

    if row < 1 or row > 3 or col < 1 or col > 3 then
        return
    end

    if board[row][col] ~= "" then
        return
    end

    -- Ход игрока
    board[row][col] = "X"
    currentPlayer = "O"

    local result = checkWinner()
    if result then
        gameOver = true
        if result == "draw" then
            winner = ""
        else
            winner = result
        end
        drawBoard()
        return
    end

    drawBoard()

    -- Ход бота с небольшой задержкой
    task.wait(0.3)
    botMove()
end)

-- Инициализация
drawBoard()
print("Крестики-нолики запущены! Игрок играет за X, бот за O.")
