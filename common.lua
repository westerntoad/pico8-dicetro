particles = {}
can_slowdown = false
selected = 1
body = ''
sub_body = ''
rerolls_left = 5
shop = {}

ante = {
    1, 3, 5, 7, 10, 15, 20,
    25, 30, 35, 40, 45, 50,
    60, 70, 80, 100, 125, 150,
    32767
}

curr_ante = 1
-- 0 = moving dice
-- 1 = picking dice
-- 2 = showing scored hand
-- 3 = transition to shop
-- 4 = shop
state = 0
state_t = 0
game_speed = 1
bank = 0
score = 0
rerolls = 5

dice = {}
entities = {}

function draw_face(face, x0, y0, highlight)
    local size = 15
    x1 = x0 + size
    y1 = y0 + size
    
    rectfill(x0+1, y0+1, x1-1, y1-1, 7)
    line(x0+1, y0, x1-1, y0, 6)
    line(x0+1, y1, x1-1, y1, 6)
    line(x0, y0+1, x0, y1-1, 6)
    line(x1, y0+1, x1, y1-1, 6)
    pset(x0+1,y0+1, 6)
    pset(x1-1,y0+1, 6)
    pset(x0+1,y1-1, 6)
    pset(x1-1,y1-1, 6)
    
    sspr(54 + 10 * (face-1), 0, 10, 10, x0 + 3, y0 + 3)
    
    if highlight then
        rect(x0-1, y0-1, x1+1, y1+1, 8)
    end
end

function draw_die(die)
    --print('x.   ' .. die.x, 7)
    --print('y.   ' .. die.y, 7)
    --print('ang. ' .. die.ang, 7)
    --print('fac. ' .. die.faces[1])

    local sx = 18 * (2 - abs((die.ang % 4) - 2))
    local flip_v = die.ang >= 3 and die.ang <= 5
    local flip_h = die.ang >= 5
    
    sspr(sx,0,18,18,die.x,die.y,18,18, flip_h, flip_v)
    
    -- draw faces
    if die.rot_speed == 0 then
        sx = ((die.faces[1] - 1) % 3) * 8
        local sy = 18 + (flr((die.faces[1] - 1) / 3) * 5)
        sspr(sx, sy, 8, 5, die.x + 5, die.y + 2, 8, 5)
    end
end

function calc_score()
    local faces = {}
    for _,die in pairs(dice) do
        add(faces, die.faces[1])
    end
    local mult = get_mult(faces)
    body = mult.name
    sub_body = 'x'..mult.mult
    score = flr(score * mult.mult)
end

function get_mult(faces)
    -- high pip         x1
    -- pair             x1.5
    -- three-of-a-kind  x2
    -- two pair         x2
    -- full house       x3
    -- four-of-a-kind   x5
    -- five-of-a-kind   x10
    -- three pair       x15
    -- double triple    x20
    -- six-of-a-kind    x30

    local out = {}
    local cnt = {0, 0, 0, 0, 0, 0}
    local hi = 0
    local hi_num = 0
    
    for i,val in pairs(faces) do
        cnt[val] += 1
        if cnt[val] > hi then
            hi = cnt[val]
            hi_num = val
        end
    end
    
    out.selected = {hi_num}
    if hi == 6 then
        out.mult = 20
        out.name = 'six-of-a-kind'
    elseif hi == 5 then
        out.mult = 15
        out.name = 'five-of-a-kind'
    elseif hi == 4 then
        out.mult = 5
        out.name = 'four-of-a-kind'
    elseif hi == 3 then
        local hi_2 = 0
        local hi_num_2 = 0
        for i,d_cnt in pairs(cnt) do
            if d_cnt > hi_2 and d_cnt != 3 do
                hi_2 = d_cnt
                hi_num_2 = i
            end
        end
        
        if hi_2 == 3 then
            out.mult = 20
            out.name = 'double triple'
            out.selected[2] = hi_num_2
        elseif hi_2 == 2 then
            out.mult = 3
            out.name = 'full house'
            out.selected[2] = hi_num_2
        else
            out.mult = 2
            out.name = 'three-of-a-kind'
        end
    elseif hi == 2 then
        out.selected = {}
        for i,d_cnt in pairs(cnt) do
            if (d_cnt == 2) add(out.selected, i)
        end
        
        if #out.selected == 3 then
            out.mult = 15
            out.name = 'three pair'
        elseif #out.selected == 2 then
            out.mult = 2
            out.name = 'two pair'
        else
            out.mult = 1.5
            out.name = 'pair'
        end
    else
        out.mult = 1
        out.name = 'high pip'
    end
    
    return out
end
