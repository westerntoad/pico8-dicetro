function _init()
    palt(0, false)
    palt(14, true)
    
    state = 0
    state_t = 0
    dice = {}
    for i=1,(rnd(6) + 1) do
        add(dice, create_die())
    end
end

-- game loop
function _draw()
    -- background
    cls(1)
    -- floor
    rectfill(0, 110, 128, 128, 3)
    
    for _,die in pairs(dice) do
        if (die.shown) draw_die(die)
        --print(die.vx)
        --print(die.vy)
    end
    
    for i,die in pairs(dice) do
        if die.rot_speed == 0 then
            local pad = 2
            local x = 64 - #dice*8 + (i-1)*16
            local y = 10
            if (die.to_reroll) y += 5
            draw_face(die.faces[1], x, y, i == selected)
        end
    end
    
    for _,p in pairs(particles) do
        draw_particle(p)
    end
            
    if state == 1 then
        local o_action = 'unlock'
        if (dice[selected].to_reroll) o_action = 'lock'
        print('🅾️ ' .. o_action, 28, 48, 7)
        
        
        local no_dice_locked = true
        for _,die in pairs(dice) do
                if (die.to_reroll) no_dice_locked = false
        end
        
        if no_dice_locked then
            print('❎ submit', 72, 48, 8)
        else
            print('❎ reroll', 72, 48, 7)
            print('(⧗' .. rerolls_left .. ' left)', 70, 56, 12)
        end
    end
    
    -- score
    local count_digits = 0
    if (score == 0) count_digits = 1
    while 10 ^ count_digits <= score do
        count_digits += 1
    end
    if (score < 0) count_digits = 1
    print(max(0, score), (128 - 4 * count_digits) / 2, 3, 10)
    
    if state == 2 then
        print(body, 64 - (#body * 2), 64, 7)
        print(sub_body, 64 - (#sub_body * 2), 72, 8)
        
        local dx = min(1, state_t - 45)
        if (score < 0) dx = min(1, score + 30)
        print('$' .. bank, dx, 3, 11)
    end
    
    if state == 3 then
        draw_shop()
    end
    
    -- debug
    --print('spd. ' .. game_speed, 7)
    --print('st.  ' .. state, 0, 40, 7)
    --print('stt. ' .. state_t, 0, 47, 7)
    --print('sel. ' .. selected, 0, 54, 7)
end

