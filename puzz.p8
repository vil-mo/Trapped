pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
inp_dirx = {-1, 1, 0, 0}
inp_diry = {0, 0, -1, 1}

max_columns = 5

function _init()
	game_state = 'menu'

	completed_levels = {}


	return_pressed = -1

	current_level = 1
	animations = {}
	particles = {}
	debug=''
end

function _update()
	if game_state == 'game' then
		for anim in all(animations) do
			anim:upd()
		end

		for obj in all(objects) do
			if obj.update then
				obj:update()
			end
		end

		for part in all(particles) do
			part.x += part.dx
			part.y += part.dy
			part.life -= 1
			if part.life <= 0 then
				del(particles, part)
			end
		end
	

		if #previous_moves > 100 then
			for i=2, 100 do
				previous_moves[i-1] = previous_moves[i]
				previous_moves[i] = nil
			end
		end

		if btnp(🅾️) and #previous_moves > 0 then
			sfx(1)

			objects = previous_moves[#previous_moves]
			del(previous_moves, previous_moves[#previous_moves])
			animations = {}
			for obj in all(objects) do
				obj.offsetx = 0
				obj.offsety = 0
				if obj.solid then
					obj.animation_openness = 8
				else
					obj.animation_openness = 3
				end
				obj.sy = 16
			end
		end


		if btn(❎) then
			return_pressed += 1


			if return_pressed > 15 then
				animation_level_end(to_menu)
			end
		elseif return_pressed >= 0 then
			if return_pressed <= 5 then
				animation_level_end(load_level, current_level)
			end
			return_pressed = -1
		end
	elseif game_state == 'menu' then
		if btnp(➡️) then
			current_level = min(current_level + 1, #levels)
			sfx(4)
		end
		if btnp(⬅️) then
			current_level = max(current_level - 1, 1)
			sfx(4)
		end
		if btnp(⬇️) then
			current_level = min(current_level + max_columns, #levels)
			sfx(4)
		end
		if btnp(⬆️) then
			current_level = max(current_level - max_columns, 1)
			sfx(4)
		end
		if btnp(🅾️) then
			sfx(2)
			animation_level_end(load_level, current_level)
		end

		for part in all(particles) do
			part.x += part.dx
			part.y += part.dy
			part.life -= 1
			if part.life <= 0 then
				del(particles, part)
			end
		end
		for part in all(part2) do
			part.x += part.dx
			part.y += part.dy
			part.life -= 1
			if part.life <= 0 then
				del(particles, part)
			end
		end
	end

	if endscr_animation then
		endscr_animation:update()
	end
end

function _draw()
	cls()
	if game_state == 'game' then
		
		for anim in all(animations) do
			if anim.draw then
				anim:draw()
			end
		end

		for obj in all(objects) do
			if obj.draw then
				obj:draw()
			end
		end
		
		for part in all(particles) do
			circfill(part.x, part.y, part.r * part.life / part.max_life, part.color)
		end


		if return_pressed > 5 then
			rectfill(3, 3, min(125 * (return_pressed-5)/10, 125), 10, 9)
			rect(3, 3, 125, 10, 7)
		end

		if current_level == 1 then
			spr(128, 16, 84, 6, 4)
			spr(134, 66, 84, 2, 2)
			spr(166, 66, 100, 2, 2)
			print("undo", 82, 89, 7)
			print("tap-restart", 82, 101, 7)
			print("hold-menu", 82, 108, 7)
		end


		print(debug, 10, 80)
	elseif game_state == 'menu' then
		local y2, y14 = sin(time()/7+0.7) * 7, sin(time()/6) * 7
		circfill(63, 305 + y2, 240, 2)
		circfill(63, 300 + y14, 200, 14)
		

		spr(64, 16, 4 + sin(time()/8+0.3) * 3, 12, 4)

		for part in all(particles) do
			circfill(part.x, part.y, part.r * part.life / part.max_life, part.color)
		end
		for part in all(part2) do
			circfill(part.x, part.y, part.r * part.life / part.max_life, part.color)
		end
	
		--spr(134, 75, 110, 2, 2)
		--print("select", 91, 115, 7)
		
		local column = 0
		local row = 0
		for lv=1, #levels do
			local c = 1
			if current_level == lv then
				c = 15
			elseif completed_levels[lv] then
				c = 9
			end
			rectfill(11 + 22 * column, 43 + 22 * row, 11 + 22 * column + 18, 43 + 22 * row + 18, c)
			rect(11 + 22 * column, 43 + 22 * row, 11 + 22 * column + 18, 43 + 22 * row + 18, 7)
			if column + 1 + row * 5 < 10 then
				print(lv, 11 + 22 * column + 8, 43 + 22 * row + 7, 7)
			else
				print(lv, 11 + 22 * column + 6, 43 + 22 * row + 7, 7)
			end
			

			column += 1
			if column >= max_columns then
				column = 0
				row += 1
			end
		end
	end

	if endscr_animation then
		endscr_animation:draw()
	end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end


function qsort(a,c,l,r)
    c,l,r=c or ascending,l or 1,r or #a
    if l<r then
        if c(a[r],a[l]) then
            a[l],a[r]=a[r],a[l]
        end
        local lp,rp,k,p,q=l+1,r-1,l+1,a[l],a[r]
        while k<=rp do
            if c(a[k],p) then
                a[k],a[lp]=a[lp],a[k]
                lp+=1
            elseif not c(a[k],q) then
                while c(q,a[rp]) and k<rp do
                    rp-=1
                end
                a[k],a[rp]=a[rp],a[k]
                rp-=1
                if c(a[k],p) then
                    a[k],a[lp]=a[lp],a[k]
                    lp+=1
                end
            end
            k+=1
        end
        lp-=1
        rp+=1
        a[l],a[lp]=a[lp],a[l]
        a[r],a[rp]=a[rp],a[r]
        qsort(a,c,l,lp-1       )
        qsort(a,c,  lp+1,rp-1  )
        qsort(a,c,       rp+1,r)
    end
end
-->8
-- tile creation

properties = {}
properties['r'] = function(obj)
	obj.color = 8
end
properties['g'] = function(obj)
	obj.color = 3
end
properties['y'] = function(obj)
	obj.color = 10
end
properties['p'] = function(obj)
	obj.color = 2
end
properties['o'] = function(obj)
	obj.color = 9
end
properties['t'] = function(obj)
	obj.solid = true
end
properties['f'] = function(obj)
	obj.solid = false
end
properties['d'] = function(obj)
	obj.swiching_solid_every_move = true
end
properties['a'] = function(obj)
	obj.activatable = true
end

function load_level(lvl_num)
	game_state = 'game'
	previous_moves = {}
	current_level = lvl_num
	local lvl = levels[lvl_num]

	
	objects = {}
	local y = 0
	
	for s in all(lvl) do
	 local x = 0
		local looking_for_property = false
		local property = ''
		for v in all(s) do
			if looking_for_property then
				property = property..v
				looking_for_property = false
			else
				local reseting_property = true

				if tonum(v) then
					tile_ground(x, y, tonum(v), property)
					x += 1
				elseif v == '-' then
					x += 1
				elseif v == '|' then
					tile_vhwall(x, y, 'h', property)
				elseif v == '_' then
					tile_vhwall(x, y, 'v', property)
				elseif v == 'p' then
					tile_player(x, y, property)
				elseif v == 'w' then
					tile_win(x, y, property)
				elseif v == 'b' then
					tile_box(x, y, property)
				elseif v == 'a' then
					tile_activator(x, y, property)
					x += 1
				elseif v == 't' then
					tile_teleport(x, y, property)
					x += 1
				elseif v == '.' then
					looking_for_property = true
					reseting_property = false
				end

				if reseting_property then
					property = ''
				end
			end
		end
		
		y += 1
	end

	qsort(objects, sort_by_layer)
	update_tiles()
end

function sort_by_layer(a,b)
	return a.layer < b.layer
end

function create_tile(tox, toy)
	local tile = {
		tag = 'tile',
		x = tox,
		y = toy,
		layer = 0,
		offsetx = 0,
		offsety = 0,
	}

	add(objects, tile)

	return tile
end

function apply_properties(obj, prop)
	for p in all(prop) do
		properties[p](obj)
	end
end

function tile_vhwall(tox,toy,ori, p)
	local vhwall = create_tile(tox, toy)
	vhwall.layer = 1
	vhwall.solid = true
	vhwall.color = 7
	
	if ori=='h' then
		vhwall.tag = 'hwall'
	else
		vhwall.tag = 'vwall'
	end

	function vhwall:draw()
		if self.tag=='hwall' then
			rectfill(self.x*16+15, self.y*16, self.x*16+16, self.y*16 + self.animation_openness, self.color)
			rectfill(self.x*16+15, self.y*16+16 - self.animation_openness, self.x*16+16, self.y*16+15, self.color)
		else
			rectfill(self.x*16, self.y*16+15, self.x*16 + self.animation_openness, self.y*16+16, self.color)
			rectfill(self.x*16 + 16 - self.animation_openness, self.y*16 + 15, self.x*16+15, self.y*16+16, self.color)
		end
	end

	function vhwall:change_solid(val)
		self.solid = val
		if self.solid then
			animation_vhwall(self, 1)
		else
			animation_vhwall(self, -1)
		end
	end

	apply_properties(vhwall, p)

	if vhwall.solid then
		vhwall.animation_openness = 8
	else
		vhwall.animation_openness = 3
	end
end


function tile_ground(tox,toy,toamount, p)
	local ground = create_tile(tox, toy)
	ground.tag = 'ground'
	ground.amount = toamount
	ground.standable = true
	ground.s = 16

	function ground:draw()
		sspr(24, 0, 16, 16,self.x * 16 + (16 - self.s)/2,self.y * 16 + (16 - self.s)/2, self.s, self.s)
		for i=2, self.amount do
			rect(self.x * 16 - 1 + i * 2, self.y * 16 - 1 + i * 2, self.x * 16 + 16 - i * 2, self.y * 16 + 16 - i * 2, 13)
		end
		if self.amount > 1 then
			print(self.amount,self.x * 16+2,self.y * 16+2, 7) 
		end
	end

	function ground:destroy()
		self.amount -= 1
		if self.amount == 0 then
			animation_ground_destr(self)
			del(objects, self)
		end
	end

	apply_properties(ground, p)
end

function tile_teleport(tox,toy, p)
	local tele = create_tile(tox, toy)
	tele.color = 7
	tele.tag = 'tele'
	tele.standable = true


	function tele:draw()
		spr(3,self.x * 16,self.y * 16,2,2)

		clip(self.x * 16 + 2,self.y * 16 + 2, 12, 12)
		rectfill(self.x * 16 + 2,self.y * 16 + 2, self.x * 16 + 13,self.y * 16 + 13, self.color)
		local t = time() * 6

		local r1 = t % 13
		circ(self.x * 16 + 7,self.y * 16 + 7, r1, 7)
		circ(self.x * 16 + 8,self.y * 16 + 8, r1, 7)
		circ(self.x * 16 + 7,self.y * 16 + 8, r1, 7)
		circ(self.x * 16 + 8,self.y * 16 + 7, r1, 7)
		clip()
		pset(self.x * 16 + 2, self.y * 16 + 2, 1)
		pset(self.x * 16 + 2, self.y * 16 + 13, 1)
		pset(self.x * 16 + 13, self.y * 16 + 13, 1)
		pset(self.x * 16 + 13, self.y * 16 + 2, 1)
	end

	function tele:get_opposite()
		for obj in all(objects) do
			if obj.tag == 'tele' and obj.color == self.color and not(obj.x == self.x and obj.y == self.y) then
				return obj
			end
		end
	end

	function tele:swap()
	
		local ot_end = self:get_opposite()
		local my_obj = get_tiles_on(self.x, self.y)
		del(my_obj, self)
		local ot_obj = get_tiles_on(ot_end.x, ot_end.y)
		del(ot_obj, ot_end)

		for obj in all(ot_obj) do
			if obj.tag == 'player' or obj.tag == 'box' then
				obj.x = self.x
				obj.y = self.y
				animation_teleport(obj, ot_end)
			end
		end
		for obj in all(my_obj) do
			if obj.tag == 'player' or obj.tag == 'box' then
				obj.x = ot_end.x
				obj.y = ot_end.y
				animation_teleport(obj, self)
			end
		end
	end

	apply_properties(tele, p)
end

function tile_activator(tox, toy, p)
	local act = create_tile(tox, toy)
	act.tag = 'act'
	act.standable = true
	act.color = 7
	act.activated = false

	function act:draw()
		spr(11,self.x * 16,self.y * 16,2,2)
		for x = self.x * 16, self.x * 16 + 15 do
			for y = self.y * 16, self.y * 16 + 15 do
				if pget(x, y) == 15 then
					pset(x, y, self.color)
				end
			end
		end
	end

	function act:activate()
		self.activated = not self.activated
		for obj in all(objects) do
			if obj.activatable and obj.color == self.color then
				if obj.tag == 'hwall' or obj.tag == 'vwall' then
					obj:change_solid(not obj.solid)
				end
			end
		end
	end

	apply_properties(act, p)
end

function tile_win(tox, toy, p)
	local win = create_tile(tox, toy)
	win.tag = 'win'
	win.standable = true
	win.layer = 2

	win.prat_timer = 0
	function win:update()
		self.prat_timer += 1
		if self.prat_timer >= 10 then
			self.prat_timer = 0
			create_particle(self.x * 16 + 8, self.y * 16 + 8, 2, 10, 0.2 + rnd(0.2), rnd(), rnd(20)+20)
		end

	end

	function win:draw()
		spr(7,self.x * 16,self.y * 16,2,2)
	end

	function win:collect()
		del(objects, self)
		for i=1, 6 do
			create_particle(self.x * 16 + 8, self.y * 16 + 8, rnd(3)+1, 10, 0.5 + rnd(1), rnd(), rnd(30)+30)
		end
		sfx(6)
	end

	apply_properties(win, p)
end

function tile_box(tox, toy, p)
	local box = create_tile(tox, toy)
	box.tag = 'box'
	box.solid = true
	box.layer = 1
	box.color = 4
	box.sy = 16



	function box:draw()
		self.color = 4
		for obj in all(get_tiles_on(self.x, self.y)) do
			if obj.tag == 'act' then
				self.color = obj.color
				break
			end
		end
		rectfill(self.x * 16 + self.offsetx + 3, self.y * 16 + self.offsety + 3 + (16 - self.sy) / 2, self.x * 16 + self.offsetx + 12, self.y * 16 + self.offsety + 12 - (16 - self.sy) / 2, self.color)
		sspr(72, 0, 16, 16, self.x * 16 + self.offsetx, self.y * 16 + self.offsety + (16 - self.sy) / 2, 16, self.sy)
	end

	apply_properties(box, p)
end


function tile_player(tox,toy, p)
	local player = create_tile(tox, toy)
	player.tag = 'player'
	player.layer = 2
	player.color = 2
	player.sy = 16
	player.flipped = false

	function player:update()
		for dir=1, 4 do
			if btnp(dir-1) then
				sfx(0)
				if dir == 1 then
					self.flipped = true
				elseif dir == 2 then
					self.flipped = false
				end

				add(previous_moves, deepcopy(objects))

				local moved = move_object(self, dir)
				local state_changed = moved

				for obj in all(objects) do
					if moved and obj.tag == 'ground' and obj.x == self.x - inp_dirx[dir] and obj.y == self.y - inp_diry[dir] then
						obj:destroy()
					end
					if not moved and obj.tag == 'box' and obj.x == self.x + inp_dirx[dir] and obj.y == self.y + inp_diry[dir] then
						obj.solid = false
						if can_move(self.x, self.y, dir) then
							local box_moved = move_object(obj, dir)
							state_changed = box_moved
							if box_moved then
								for tel in all(get_tiles_on(obj.x, obj.y)) do
									if tel.tag == 'tele' then
										tel:swap()
									end
								end
							end
						end
						obj.solid = true
					end
					if obj.tag == 'win' and obj.x == self.x and obj.y == self.y then
						obj:collect()
						state_changed = true
					end
				end

				if moved then
					for obj in all(get_tiles_on(self.x, self.y)) do
						if obj.tag == 'tele' then
							obj:swap()
						end
					end

					for obj in all(get_tiles_on(self.x, self.y)) do
						if obj.tag == 'win' then
							obj:collect()
						end
					end
				end

				if state_changed then
					update_tiles()
				else
				 	del(previous_moves, previous_moves[#previous_moves])
				end


			end
		end
	end
	
	function player:draw()
		sspr(8, 0, 16, 16, self.x * 16 + self.offsetx, self.y * 16 + self.offsety + (16 - self.sy) / 2, 16, self.sy, self.flipped)
	end

	apply_properties(player, p)
end
-->8
-- map logic
inp_wori = {'hwall','hwall','vwall','vwall'}
inp_block = {1, 0, 1, 0}

function update_tiles()
	local boxes = {}
	local acts = {}
	local wins = {}
	for obj in all(objects) do
		if obj.swiching_solid_every_move then
			obj:change_solid(not obj.solid)
		end
		if obj.tag == 'box' then
			add(boxes, obj)
		end
		if obj.tag == 'act' then
			add(acts, obj)
		end
		if obj.tag == 'win' then
			add(wins, obj)
		end
	end

	if #wins == 0 then
		level_complete()
	end

	for act in all(acts) do
		local has_box = false
		for box in all(boxes) do
			if box.x == act.x and box.y == act.y then
				has_box = true
				break
			end
		end
		if (has_box and not act.activated) or(not has_box and act.activated) then
			act:activate() 
		end
	end
end

function move_object(obj, dir)
	if can_move(obj.x, obj.y, dir) then
		obj.x += inp_dirx[dir]
		obj.y += inp_diry[dir]
		animation_movement(obj, dir)

		
		return true
	end

	animation_bump(obj, dir)
	return false
end

function can_move(fromx, fromy, dir)
	local tox = fromx+inp_dirx[dir]
	local toy = fromy+inp_diry[dir]
	local obstacle = false
	local has_ground = false
	for obj in all(objects) do
		if (obj.solid and obj.tag ~= 'hwall' and obj.tag ~= 'vwall' and obj.x==tox and obj.y==toy) or 
				(obj.tag==inp_wori[dir] and obj.solid and obj.x==(fromx+inp_dirx[dir]*inp_block[dir]) and obj.y==(fromy+inp_diry[dir]*inp_block[dir]))
			then
		 	obstacle = true
		end
		if obj.standable and obj.x == (fromx+inp_dirx[dir]) and obj.y == fromy+inp_diry[dir] then
			has_ground = true
		end
	end
	if has_ground and not obstacle then
		return true
	end
	return false
end

function get_tiles_on(onx, ony)
	local tiles = {}
	for obj in all(objects) do
		if obj.x == onx and obj.y == ony then
			add(tiles, obj)
		end
	end
	return tiles
end

function level_complete()
	completed_levels[current_level] = true
	if current_level >= #levels then
		animation_level_end(to_menu, nil, 90, true)
	else
		animation_level_end(load_level, current_level + 1, 90, true)
	end
end

function to_menu()
	game_state = 'menu'
end

-->8
-- animations

function create_particle(x, y, r, col, speed, dir, life)
	local part = {
		x = x,
		y = y,
		r = r,
		color = col,
		dx = speed * cos(dir),
		dy = speed * sin(dir),
		life = life,
		max_life = life,
	}

	add(particles, part)
	

	return part
end


function create_animation(obj)
	local anim = {}

	anim.obj = obj
	anim.progress = 0

	add(animations, anim)

	return anim
end

function animation_level_end(to_do, p, wait, comp)
	if not endscr_animation then

		return_pressed = -1
		endscr_animation = {}

		endscr_animation.progress = 0
		endscr_animation.wait = wait or 0
		endscr_animation.time = 0


		local an1_st_end_scx, an1_st_end_scy, an1_st_time, an_lenght, sh_scr_l = 58, 40, 20, 30, 35
		local scx, scy, an1_st_accx, an1_st_accy = 0, 0, -2 * an1_st_end_scx / (an1_st_time * an1_st_time), -2 * an1_st_end_scy / (an1_st_time * an1_st_time)
		local an_speedx, an_speedy = 2 * an1_st_end_scx / an1_st_time, 2 * an1_st_end_scy / an1_st_time
		local dx_2, dy_2, t_2 = an1_st_end_scx - 48, an1_st_end_scy - 32, an_lenght - an1_st_time
		local an2_accx, an2_accy = 2 * dx_2 / (t_2 * t_2), 2 * dy_2 / (t_2 * t_2)

		function endscr_animation:update()
			self.wait -= 1
			self.time += 1

			if self.wait <= 0 then
				self.progress += 1
				if self.progress == 8 then
					to_do(p)
					particles = {}
				elseif self.progress >= 16 then
					endscr_animation = nil
				end
			end

			if self.time < an1_st_time then
				scx += an_speedx
				scy += an_speedy

				an_speedx += an1_st_accx
				an_speedy += an1_st_accy
			elseif self.time < an_lenght then
				scx -= an_speedx
				scy -= an_speedy

				an_speedx += an2_accx
				an_speedy += an2_accy
			elseif self.time == an_lenght then
				scx, scy = 48, 32
				for i=1, 15 do
					local d = rnd()
					create_particle(63 + cos(d) * 20, 63 + sin(d) * 14, 2 + rnd(7), 7, 0.5 + rnd(3), d, 10 + rnd(40))
				end
				
				sfx(7)
				
				camera((rnd()-1) * 3, (rnd()-1) * 3)
			elseif self.time < sh_scr_l then
				camera((rnd()-1) * 3, (rnd()-1) * 3)
			elseif self.time == sh_scr_l then
				camera(0, 0)
			end
		end

		function endscr_animation:draw()
			if comp and self.progress < 8 then
				local v, sx, sy = ceil(self.time/4), 80, 64
				if v % 3 == 0 then
					sx, sy = 0, 96
				elseif v % 3 == 1 then
					sx, sy = 48, 96
				end

				sspr(sx, sy, 48, 32, 63 - scx / 2, 63 - scy / 2, scx, scy)
				if self.time >= an_lenght and self.time < sh_scr_l then
					for x=39, 87 do
						for y=47, 79 do
							if not((x == 39 and y == 47) or (x == 39 and y == 79) or (x == 87 and y == 47) or (x == 87 and y == 79)) then
								pset(x, y, 7)
							end
						end
					end
				end
			end
			
			rectfill(-128 + self.progress * 16, 0, self.progress * 16, 128, 0)
		end
	end
end

function animation_teleport(obj, tel)
	local anim = create_animation(obj)

	local opposite = tel:get_opposite()

	obj.offsetx -= (opposite.x - tel.x) * 16
	obj.offsety -= (opposite.y - tel.y) * 16

	function anim:upd()
		self.progress += 1

		if self.progress <= 4 then
			self.obj.sy -= 4
		else
			if self.progress == 5 then
				self.obj.offsetx += (opposite.x - tel.x) * 16
				self.obj.offsety += (opposite.y - tel.y) * 16
			end
			self.obj.sy += 4
		end

		if self.progress >= 8 then
			del(animations, self)
		end
	end
end

function animation_ground_destr(obj)
	local anim = create_animation(obj)

	function anim:upd()
		obj.s -= 2
		if obj.s <= 5 then
			create_particle(obj.x*16+8, obj.y*16+8, 2+rnd(2), 1, 0.1+rnd(0.2), rnd(), 10+rnd(15))
			del(animations, self)
		end
	end

	function anim:draw()
		self.obj:draw()
	end
end

function animation_vhwall(obj, dir)
	local anim = create_animation(obj)

	anim.dir = dir

	function anim:upd()
		self.progress += 1
		obj.animation_openness = min(8, max(3, obj.animation_openness + dir * 2)) 
		if self.progress >= 4 then
			del(animations, self)
		end
	end
end

function animation_bump(obj, dir)
	local anim = create_animation(obj)

	anim.dir = dir

	function anim:upd()
		self.progress += 1
		if self.progress <= 2 then
			obj.offsetx += inp_dirx[self.dir]
			obj.offsety += inp_diry[self.dir]
		else
			obj.offsetx -= inp_dirx[self.dir]
			obj.offsety -= inp_diry[self.dir]
		end

		if self.progress >= 4 then
			del(animations, self)
		end
	end
end

function animation_movement(obj, dir)
	local anim = create_animation(obj)

	anim.dir = dir

	anim.obj.offsetx -= inp_dirx[dir] * 16
	anim.obj.offsety -= inp_diry[dir] * 16

	function anim:upd()
		self.progress += 1
		obj.offsetx += inp_dirx[self.dir] * 4
		obj.offsety += inp_diry[self.dir] * 4

		if self.progress >= 4 then
			del(animations, self)
		end
	end
end


-->8
-- levels

levels = {
	{
		'-- - -     - ---',
		'-- 1 1     1 1--',
		'--_1p1   _|1 1--',
		'-- 1|1     1w1--',
		'--w1 1     1 1--',
		'-- - -     - ---',
		'-- - -     - ---',
		'-- - -     - ---',
	},
	{
		'-- - -     - ---',
		'-- 1 1     1 1--',
		'--_1p1   _|1 1--',
		'-- 1 1    |1w1--',
		'--w1 1.d.t|1 1--',
		'-- - -     - ---',
		'-- - -     - ---',
		'-- - -     - ---',
	},
	{
		'-- - -      -     - --',
		'-- - -      -     - --',
		'-- - 1      1     1 --',
		'-- -b1      1     1 --',
		'--p1b1.d.f_ 1     1 --',
		'-- - -     w1     - --',
		'-- - -      -     - --',
		'-- - -      -     - --',
	},
	{
		'---  -       -     -  --',
		'---  -       -     -.ra-',
		'---  -      p1    b1  1-',
		'--1  1       1     1  1-',
		'--1 b1       1     1  1-',
		'--1  1       1     -  1-',
		'--1.ga       1    _1 _1-',
		'---  -  .g.a|1.r.a|1 w1-',
	},
	{
		'---  -     -     -  --',
		'---  -     -     -.ra-',
		'---  -    p1    b1  1-',
		'--1  1     1     1  1-',
		'--1 b1.d.t|1     1  1-',
		'--1  1     1     -  1-',
		'--1.ga     1    _1 _1-',
		'---  -.g.a|1.r.a|1 w1-',
	},
	{
		'--  -     - -  ---',
		'--  -     - -  ---',
		'--.ya    b1_1  1--',
		'--  1     2 1 _1--',
		'--  1     1 1  1--',
		'--  1     1_1_w1--',
		'-- p1.y.a|1 1 w1--',
		'--  -     - -  ---',
	},
	{
		'-  -  -       -      - -  --',
		'-  -  -       -      - -  --',
		'- p1  1  .a.g|1.a.r|_1_1w_1-',
		'-  1  1       1      1 1  1-',
		'-.ra.ra.d.t|.ra     b1 1  1-',
		'-.ra.ra.d.f|.ga     b1 1  1-',
		'-.ra.ra     .ra      1 2  1-',
		'-  -  -       -      - -  --',
	},
	{
		'-      - -  - - - --',
		'-     w1 1 b1 1 1w1-',
		'-     b1 1  1b1 1 1-',
		'-      1b1 b1 1 1 1-',
		'-      1 1  1b1 1 1-',
		'-     b1b1.ra 1 1 1-',
		'-.a.r_b1 1  1 1b1b1-',
		'-.a.r|w1 1  1b1 1p1-',
	},
	{
		'--  - - -        - --',
		'--  - - -        - --',
		'--.ga 1 1      .ga --',
		'--  1 1 1b.g.a.f|1w1-',
		'--  1b1 1      .ga --',
		'--  1 1p1        - --',
		'--  - - -        - --',
		'--  - - -        - --',
	},	{
		'--------',
		'- 11      |.pa   1 1     1-',
		'- 11   .d.t|b2   2 1     1-',
		'- 11      |.pa .pa 1    _1-',
		'- 11.a.p.f|.pab.pa 1.d.t_1-',
		'-p11      |.pa .pa|1.p.a_1-',
		'- --         -   - -    w1-',
		'--------',
	},
	{
		'- -   - - -     -      --',
		'- 1   1 1 1    |1w.g.a_1-',
		'- 1 .ra 2 2.r.a|1      1-',
		'- 1   1 1 1     1      --',
		'- 1   1 1b1    p2      --',
		'-w1|.gab1 1     1      --',
		'- 1   1 1 1     1      --',
		'- -   - - -     -      --',
	},
	{
		'-- -  --         - --',
		'-- - --         - --',
		'-- 1  11         1 --',
		'-- 1.ga1         1 --',
		'-- -  b1         1 --',
		'--p1  11.d.t.a.g|1w1-',
		'-- -  --         - --',
		'-- -  --         - --',
	},
	{
		'-- -  -         -  -       --',
		'-- 1.oa         1  1      w1-',
		'-- 1 b1        w1 _1     .oa-',
		'-- 1 b1 .a.o.f|b1  1     .oa-',
		'-- 1  1.a.o.d.f_2  1       1-',
		'-- 1  1         1  1       1-',
		'--p1  1 .a.o.f_b1.oa       --',
		'-- -  -        w1  -       --',
	},
	{
		' -           -  -      -       -     -      --',
		' -           -.ga      1      _1     1      --',
		' -.d.f_w.g.a|1  1b.p.a|3w.p.a|_1     1      --',
		' -     |.g.a_1  1     _2       2     1      --',
		'p2           2.pa      1    |.ya     1 .y.a_1-',
		' -           -  1     b1       1.y.a|2w.y.a_1-',
		' -           -  1      1       1     1      1-',
		' -           -  -      -       -     -      --',
	},
	{
		'--  -  - -     -      --',
		'--  -  - -     -      --',
		'--  1.ga|1.a.g|1w.a.g_1-',
		'--.rt |1 1     2      1-',
		'--  1  1 1     2      1-',
		'--  1  1 1    b1      --',
		'-- p1  1 1   .rt      --',
		'--  -  - -     -      --',
	},
	{
		'-  -  -   -   - -  --',
		'-  -  -   -   - -  --',
		'-  -p|1   1  _1 1 w1-',
		'-.rt  1 .rt   1 -  1-',
		'-.ot  1|_w1_|w1 1.gt-',
		'-  1  1 |w1  w1 1  1-',
		'-.gt  1   1   1 -.ot-',
		'-  -  -   -   - -  --',
	},
	{
		'--           - -   -  ---',
		'--           - -   -  ---',
		'--w.a.r|.a.r_1 1_.ra  11-',
		'--           1 1   1.gt1-',
		'--           1 1  b1  11-',
		'--         .gtp1   1  11-',
		'--           1 1   1  11-',
		'--           - -   -  ---',
	},
	{
		'-           --  -  -     -       --',
		'-           --  -  -     -       --',
		'-           11  1.ya.r.a|1 w.r.a_1-',
		'-           11.gt  1     1       1-',
		'-           11 b1  1     1       1-',
		'-         .rt1 b1.rt     1.y.a_.ra-',
		'-           11.gt p1.y.a|1      w1-',
		'-           --  -  -     -       --',
	},
	{
		'-           --  -   -     -       --',
		'-           --  -   -     -       --',
		'-w.r.a|.r.a_11  1   1     1       1-',
		'-           11.gt .ya     1       1-',
		'-           11 b1   1     1       1-',
		'-         .rt1 b1_.rt     1.y.a_.ra-',
		'-           11.gt  p1.y.a|1      w1-',
		'-           --  -   -     -       --',
	},
	{
		'  -   .ga      -  -  -      -      --',
		'.ga    b1    w|1  1  1p.a.g|1.a.g_w1-',
		'  -     1.d.t_|1  1  1      1      1-',
		'  -     1      1.rt  1      1 .d.t_1-',
		'  -     1      1  1  1     |1     w1-',
		'  -.d.f_1      1  1.rt      1      1-',
		'  -    w1      1  1  1      1      1-',
		'  -     -      -  -  -      -      --',
	},


}
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000111111111111000000000000000000000000000000000000000000000000000011111111111100000000000000000000000000
00700700000000000000000001111111111111100000000000000000000000000000000000000000000000000111111111111110000000000000000000000000
000770000000111111111000011111111111111000000000000000000000000aa000000000050555555050000111111111111110000000000000000000000000
000770000001eeeeeeee1000011111111111111000000000000000000000000aa0000000000005000050000001111ffffff11110000000000000000000000000
007007000001eeeeeeee100001111111111111100000000000000000000aa0aaaa0aa00000055000000550000111ffffffff1110000000000000000000000000
000000000001ee71ee71100001111111111111100000000000000000000aaa7777aaa00000050000000050000111ff77ffff1110000000000000000000000000
000000000001ee71ee711000011111111111111000000000000000000000a77aa77a000000050005500050000111ff7fffff1110000000000000000000000000
000000000001eeeeeeee1000011111111111111000000000000000000000aa7aa7aa000000050005500050000111ffffffff1110000000000000000000000000
000000000001eeee77ee10000111111111111110000000000000000000000a7777a0000000050000000050000111ffffffff1110000000000000000000000000
000000000001eeeeeeee1000011111111111111000000000000000000000aaaaaaaa0000000550000005500001110ffffff01110000000000000000000000000
000000000001ee1ee1ee1000011111111111111000000000000000000000aaa00aaa000000000500005000000111100000011110000000000000000000000000
000000000001110110111000011111111111111000000000000000000000aa0000aa000000050555555050000111111111111110000000000000000000000000
00000000000000000000000001111111111111100000000000000000000000000000000000000000000000000111111111111110000000000000000000000000
00000000000000000000000000111111111111000000000000000000000000000000000000000000000000000011111111111100000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000002eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000022ee0000002eeeeee0000002eeee000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000022eeeee00022eeeeeee000022eeeeee0000000000000000000000000000000000000000000000000000000000000000000
00000000000000022eeeeee00000022eeeeee00022ee22eee000022e22eeee000022eeee00000000000000000000000000000000000000000000000000000000
00000000000eee022eeeeeeee000022eeeeeee0022e0222eee00022e02222ee0022eeeeeeee00000000000000000000000000000000000000000000000000000
000000000eeeee0222ee22eeeee0022ee222ee0022e00222ee00022e000222e0022eeeeeeeeeee0022eeeeee0000000000000000000000000000000000000000
0000000eeeeee20022ee02222ee0022ee002ee0022e000222e0022ee000022e0022ee2222eeeee0022eeeeeee000000000000000000000000000000000000000
000000eeeeee200022ee00222ee0022ee002ee0022e000022e0022ee000022e0022ee000222222022eee22eeee00000000000000000000000000000000000000
0000eeeeeee2000022ee00002ee0022ee002ee0022e000022e0022ee000022e0022ee000000000022eee2222eee0000000000000000000000000000000000000
000eeeeeeee0000022ee00022ee0022ee002ee0022e00022ee0022ee00022ee0022ee000000000022ee000222eee000000000000000000000000000000000000
00eeee22eee0000022ee00eeee00022ee002ee0022e00222ee0022ee0022ee0022eee000000000022ee0000222ee000000000000000000000000000000000000
02eee222eee0000022eeeeee0000022ee002ee0022e022eee00022ee222eee0022eeeeeee00000022ee0000022eee00000000000000000000000000000000000
022e2222eee0000022eeee000000022ee002ee0022eeeeeee00022eeeeeee00022eeeeeeeeeee0022ee00000222ee00000000000000000000000000000000000
002200022ee0000022eeeeee0000022eeeeeee0002eeeee0000022eeeee0000022ee2222eeeee0022ee00000022ee00000000000000000000000000000000000
000000022eee000022ee222ee000022eeeeeee0002eee000000022ee0000000022ee000222222022eee00000022ee00000000000000000000000000000000000
000000022eee000022ee0022e000022eeeeeee0002eee000000022ee000000022eee000000000022eee00000022ee00000000000000000000000000000000000
000000022eee000022eee022ee00022ee222ee0002eee000000022ee000000022eee000000000022eee00000022ee00000000000000000000000000000000000
000000002eee0000022ee002ee00022ee002ee00022ee00000022ee0000000022eee000000000022eee00000022ee00000000000000000000000000000000000
0000000022ee0000022ee0022e00022ee002ee00022ee00000022ee0000000022eee000000000022ee000000222ee00000000000000000000000000000000000
0000000022eee000022ee0022ee0022ee002ee00022ee00000022ee00000000022eeeeee00000022ee00000222ee000000000000000000000000000000000000
0000000022eee000022ee0002ee0022ee002ee00022ee00000022ee00000000022eeeeeeeeee0022ee00022222ee000000000000000000000000000000000000
0000000002eee000022ee0002ee0022ee002ee00022ee00000022ee0000000000222222eeeee0022ee22222eeeee000000000000000000000000000000000000
00000000022ee000022ee00000000000000000000000000000000000000000000000000222220022eeeeeeeeee00000000000000000000000000000000000000
00000000022ee00000000000000000000000000000000000000000000000000000000000000000022eeeeee00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000777777777777700000000000000000007777777777777000000000000000000077777777777777777777777777777777777777777777770
00000000000000007777777777777770000000000000000077777777777777700000000000000000777777777777777777777777777777777777777777777777
00000000000000007777777777777770000000000000000077000000000000700000000000000000777111111111111111111111111111111111111111111177
00000000000000007777777077777770000000000000000077000000000000700000000000000000771111111111111111111111111111111111111111111177
00000000000000007777770007777770000000000000000077777777777000700000000000000000771111111111111111111111111111111111111111111177
0000000000000000777770000077777000000000000000007777777770000070000000000000000077111111111111111111111111111111111aa111111a1177
0000000000000000777700000007777000000000000000007777777000000770000000000000000077111a111111111111111111111aaa11111a1a11111a1177
0000000000000000777000000000777000000000000000007777700000077770000000000000000077111a1111111111111a111aaaa11111111a1a11111a1177
0000000000000000770000000000077000000000000000007770000007777770000000000000000077111a11111111a1111a111111a1111111a11a11111a1177
00000000000000007700000000000770000000000000000077000007777777700000000000000000771111a111111aa1111a111111a1111111a11a11111a1177
00000000000000007700000000000770000000000000000077000777777777700000000000000000771111a111111aa1111a111111a1111111a11a11111a1177
00000000000000007777777777777770000000000000000077000000000000700000000000000000771111a111111aa1111a111111a1111111a11a11111a1177
00000000000000007777777777777770000000000000000077000000000000700000000000000000771111a111111aa1111a111111a111111aa111a1111a1177
00000000000000007777777777777770000000000000000077777777777777700000000000000000771111a111111aa1111a111111a111111a1111a1111a1177
00000000000000000777777777777700000000000000000007777777777777000000000000000000771111a111111aa1111a111111a111111a1111a111aa1177
00000000000000000000000000000000000000000000000000000000000000000000000000000000771111a11111aaa1111a111111a111111a1111a111a11177
07777777777777000777777777777700077777777777770007777777777777000000000000000000771111a11111a1a1111a111111a111111a1111a111a11177
777777777777777077777777777777707777777777777770777777777777777000000000000000007711111a1111a1a1111a111111a111111a1111a111a11177
777777770007777077777777777777707777000777777770770077777770077000000000000000007711111a111aa1a111aa111111a111111a1111a111a11177
777777700007777077777777777777707777000077777770770007777700077000000000000000007711111a111a11a111a1111111a111111a1111a111a11177
777777000007777077000000000007707777000007777770777000777000777000000000000000007711111a111a111a11a1111111a111111a11111a11a11177
777770000007777077000000000007707777000000777770777700070007777000000000000000007711111a111a111a11a1111111a111111a11111a11a11177
777700000007777077000000000007707777000000077770777770000077777000000000000000007711111a111a111a1a11111111a111111a11111a11a11177
777000000007777077700000000077707777000000007770777777000777777000000000000000007711111aa1a1111a1a11111111a111111a11111a11a11177
7777000000077770777700000007777077770000000777707777700000777770000000000000000077111111a1a1111a1a1111111aa111111a11111a11a11177
7777700000077770777770000077777077770000007777707777000700077770000000000000000077111111a1a1111a1a1111111a1111111a111111a1a11177
7777770000077770777777000777777077770000077777707770007770007770000000000000000077111111aa111111aa1111111aaaa1111a111111aa111177
777777700007777077777770777777707777000077777770770007777700077000000000000000007711111111111111111111aaaa1111111111111111111177
77777777000777707777777777777770777700077777777077007777777007700000000000000000771111111111111111111111111111111111111111111177
77777777777777707777777777777770777777777777777077777777777777700000000000000000777111111111111111111111111111111111111111111177
07777777777777000777777777777700077777777777770007777777777777000000000000000000777777777777777777777777777777777777777777777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777777777777777777777777777777777777770
07777777777777777777777777777777777777777777777007777777777777777777777777777777777777777777777007777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77711111111111111111111111111111111111111111117777711111111111111111111111111111111111111111117777711111111111111111111111111111
77111111111111111111111111111111111111111111117777111111111111111111111111111111111111111111117777111111111111111111111111111111
7711111111111111111111111111111111111111111111777711111111111111111111111111111111111111111a117777111111111111111111111111111111
771111111111111111111111111111111111a111111a117777111111111111111111111111111111111aa111111a117777111111111111111111111111111111
77111a11111111111111111111aaaa11111a1a11111a117777111111111111111111111111111111111aa111111a117777111a11111111111111111aaaaaaaa1
77111a1111111111111a111aaaaa1111111a1a11111a117777111a1111111111111a111aaaaaaa11111aa111111a117777111a111111111111111111111a1111
77111a1111111a11111a1111111a111111a11a11111a117777111a1111111a11111a111111a1111111a1a111111a117777111a1111111a1111a1111111aa1111
77111a111111a1a1111a1111111a111111a11a1111a1117777111a1111111a11111a111111a1111111a1a111111a1177771111a111111a1111a1111111a11111
77111a111111a1a111aa1111111a111111a11a1111a1117777111a1111111aa1111a111111a1111111a1a11111aa1177771111a111111a1111a1111111a11111
77111a111111a1a111a1111111a1111111a11a1111a1117777111a1111111aa1111a111111a1111111a1aa1111a11177771111a111111a1111a1111111a11111
77111a111111a1a111a1111111a1111111a11a1111a1117777111aa111111aa1111a111111a1111111a11a1111a11177771111a111111a1111a1111111a11111
771111a11111a1a111a1111111a1111111a11a1111a11177771111a111111aa1111a111111a1111111a11a1111a11177771111a111111a1111a1111111a11111
771111a11111a1a111a1111111a1111111a11a1111a11177771111a111111aa111aa111111a111111a111a1111a11177771111a11111aa1111a1111111a11111
771111a11111a1a111a1111111a1111111a111a111a111777711111a1111aaa111a1111111a111111a1111a111a11177771111a11111aa111a11111111a11111
771111a11111a1a111a1111111a1111111a111a111a111777711111a1111a1a111a1111111a111111a1111a11aa11177771111a11111aa111a11111111a11111
771111a1111aa1a111a1111111a1111111a111a111a111777711111a1111a11a11a1111111a111111a1111a11a111177771111a11111aa111a11111111a11111
771111a1111a11a11a11111111a111111a1111a111a111777711111a1111a11a1aa111111a1111111a1111a11a1111777711111a1111aa111a11111111a11111
771111a1111a11a11a11111111a111111a11111a1a1111777711111a1111a11a1a1111111a1111111a1111a11a1111777711111a111a1a111a11111111a11111
771111a111a1111a1a11111111a111111a11111a1a1111777711111a111aa11a1a1111111a1111111a11111a1a1111777711111a111a1a111a11111111a11111
771111a111a1111a1a1111111a1111111a11111a1a1111777711111a111a111a1a1111111a1111111a11111a1a1111777711111a111a1aa11a11111111a11111
771111a111a1111a1a1111111a1111111a11111a1a1111777711111aa11a111a1a1111111a111111a111111a1a1111777711111a11a111a1a11111111aa11111
771111aa11a1111a1a1111111a1111111a11111aaa11117777111111a11a111a1a1111111a111111a111111a1a1111777711111aa1a111a1a11111111a111111
7711111a11a1111a1a1111111a1111111a111111a111117777111111a1aa111aa11111111a111111a111111aa111117777111111aa1111aa111111111a111111
7711111a11a1111a1a1111111a111111a1111111a111117777111111a1a11111a11111111a111111a111111aa111117777111111aa1111aa111111111a111111
7711111a1a111111aa1111111a111111a1111111a111117777111111a1a11111a11111111a111111a111111aa111117777111111a111111111111aaaaaaaaa11
77111111a1111111111111aaaaaaa111111111111111117777111111aaa111111111111aaaaaa111111111111111117777111111111111111111111111111111
7711111111111111111111111111111111111111111111777711111111111111111111aa11111111111111111111117777111111111111111111111111111111
77711111111111111111111111111111111111111111117777711111111111111111111111111111111111111111117777711111111111111111111111111111
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
07777777777777777777777777777777777777777777777007777777777777777777777777777777777777777777777007777777777777777777777777777777
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
888888888888888888888888888888888888888888888888888888888888888888888888888888888882282288882288228882228228888888ff888888228888
888882888888888ff8ff8ff88888888888888888888888888888888888888888888888888888888888228882288822222288822282288888ff8f888888222888
88888288828888888888888888888888888888888888888888888888888888888888888888888888882288822888282282888222888888ff888f888888288888
888882888282888ff8ff8ff888888888888888888888888888888888888888888888888888888888882288822888222222888888222888ff888f888822288888
8888828282828888888888888888888888888888888888888888888888888888888888888888888888228882288882222888822822288888ff8f888222288888
888882828282888ff8ff8ff8888888888888888888888888888888888888888888888888888888888882282288888288288882282228888888ff888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555000000000000555555555555555555555555555555555500000000000055000000000000555
555555e555566656665555e555555555555555556656665665555066006000000555555555555555565555665566566655506660666000055066606660000555
55555ee555565656565555ee55555555555555565556565656555006006000000555555555555555565556565656565655506060606000055060606060000555
5555eee555565656665555eee5555555555555566656665656555006006660000555555555555555565556565656566655506060606000055060606060000555
55555ee555565656565555ee55555555555555555656555656555006006060000555555555555555565556565656565555506060606000055060606060000555
555555e555566656665555e555555555555555566556555666555066606660000555555555555555566656655665565555506660666000055066606660000555
55555555555555555555555555555555555555555555555555555000000000000555555555555555555555555555555555500000000000055000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555566666566666566666577777555555588888888566666666566666666566666666566666666566666666566666666566666666555555555
55555665566566655565566565556565556575757555555588877888566666766566666677566777776566667776566766666566766676566677666555dd5555
5555656565555655556656656665656665657575755555558878878856667767656666776756676667656666767656767666657676767656677776655d55d555
5555656565555655556656656555656655657555755555558788887856776667656677666756676667656666767657666767657777777756776677655d55d555
55556565655556555566566565666566656577757555555578888887576666667577666667577766677577777677576667767567676767577666677555dd5555
55556655566556555565556565556565556577757555555588888888566666666566666666566666666566666666566666666567666667566666666555555555
55555555555555555566666566666566666577777555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555005005005005005dd500566555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555565655665655555005005005005005dd5665665555555dddddddd5dddddddd5777777775dddddddd5dddddddd5dddddddd5dddddddd5dddddddd555555555
555565656565655555005005005005005775665665555555dddddddd5d55ddddd5775775775ddd55ddd5ddddd5dd5dd5ddddd5dddddddd5dddddddd555555555
555565656565655555005005005005665775665665555555dddddddd5d555dddd5755755775dddddddd5dddd55dd5dd55dddd55d5d5d5d5d55dd55d555555555
555566656565655555005005005665665775665665555555ddd55ddd5dddd555d5775575575d5d55d5d5ddd555dd5dd555ddd55d5d5d5d5d55dd55d555555555
555556556655666555005005665665665775665665555555dddddddd5ddddd55d5775775775d5d55d5d5dd5555dd5dd5555dd5dddddddd5dddddddd555555555
555555555555555555005665665665665775665665555555dddddddd5dddddddd5777777775dddddddd5dddddddd5dddddddd5dddddddd5dddddddd555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005500000000000000000000000000000550000000000000000000000000000055011111111111111111aaaaa111110555
55500770000066600eee00c0c00ddd005500770000066600eee00c0c00ddd005500770707066600eee00c0c00ddd005501771717166611eee1accca1ddd10555
55507000000000600e0e00c0c00d00005507000000000600e0e00c0c00d00005507000777000600e0e00c0c00d00005507111777111611e1e1aaaca1d1110555
55507000000066600e0e00ccc00ddd005507000000066600e0e00ccc00ddd005507000707066600e0e00ccc00ddd005507111717166611e1e1aacca1ddd10555
55507000000060000e0e0000c0000d005507000000060000e0e0000c0000d005507000777060000e0e0000c0000d005507111777161111e1e1aaaca111d10555
55500770000066600eee0000c00ddd005500770000066600eee0000c00ddd005500770707066600eee0000c00ddd005501771717166611eee1accca1ddd10555
555000000000000000000000000000005500000000000000000000000000000550000000000000000000000000000055011111111111111111aaaaa111110555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507700707066600eee00c0000ddd005507700707066600eee00c0c00ddd005507770000066600eee00c0000ddd005500770707066600eee00c0c00ddd00555
55507070777000600e0e00c0000d00005507070777000600e0e00c0c00d00005507000000000600e0e00c0000d00005507000777000600e0e00c0c00d0000555
55507070707066600e0e00ccc00ddd005507070707066600e0e00ccc00ddd005507700000066600e0e00ccc00ddd005507000707066600e0e00ccc00ddd00555
55507070777060000e0e00c0c0000d005507070777060000e0e0000c0000d005507000000060000e0e00c0c0000d005507000777060000e0e0000c0000d00555
55507770707066600eee00ccc00ddd005507770707066600eee0000c00ddd005507770000066600eee00ccc00ddd005500770707066600eee0000c00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00c0000ddd0055000000000000000000000000000005507770000066600eee00c0000ddd005500000000000000000000000000000555
55507000000000600e0e00c0000d000055000000000000000000000000000005507000000000600e0e00c0000d00005500000000000000000000000000000555
55507700000066600e0e00ccc00ddd0055000000000000000000000000000005507700000066600e0e00ccc00ddd005500000000000000000000000000000555
55507000000060000e0e00c0c0000d0055000000000000000000000000000005507000000060000e0e00c0c0000d005500000000000000000000000000000555
55507000000066600eee00ccc00ddd0055001000100010000100001000010005507000000066600eee00ccc00ddd005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000010555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000171555
55500770707066600eee00c0000ddd0055000000000000000000000000000005500770707066600eee00c0000ddd005500000000000000000000000000177155
55507000777000600e0e00c0000d000055000000000000000000000000000005507000777000600e0e00c0000d00005500000000000000000000000000177715
55507000707066600e0e00ccc00ddd0055000000000000000000000000000005507000707066600e0e00ccc00ddd005500000000000000000000000000177771
55507070777060000e0e00c0c0000d0055000000000000000000000000000005507070777060000e0e00c0c0000d005500000000000000000000000000177115
55507770707066600eee00ccc00ddd0055001000100010000100001000010005507770707066600eee00ccc00ddd005500100010001000010000100001011715
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005507770000066600eee00ccc00ddd0055000000000000000000000000000005507770000066600eee00c0000ddd00555
555000000000000000000000000000005507000000000600e0e0000c00d000055000000000000000000000000000005507000000000600e0e00c0000d0000555
555000000000000000000000000000005507700000066600e0e00ccc00ddd0055000000000000000000000000000005507700000066600e0e00ccc00ddd00555
555000000000000000000000000000005507000000060000e0e00c000000d0055000000000000000000000000000005507000000060000e0e00c0c0000d00555
555001000100010000100001000010005507000000066600eee00ccc00ddd0055001000100010000100001000010005507000000066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005500770707066600eee00ccc00ddd0055000000000000000000000000000005500770707066600eee00c0000ddd00555
555000000000000000000000000000005507000777000600e0e0000c00d000055000000000000000000000000000005507000777000600e0e00c0000d0000555
555000000000000000000000000000005507000707066600e0e00ccc00ddd0055000000000000000000000000000005507000707066600e0e00ccc00ddd00555
555000000000000000000000000000005507070777060000e0e00c000000d0055000000000000000000000000000005507070777060000e0e00c0c0000d00555
555001000100010000100001000010005507770707066600eee00ccc00ddd0055001000100010000100001000010005507770707066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555dd555dd5ddd5ddd555555ddd5d5d5ddd5ddd555555dd55ddd5ddd5d5d5dd55ddd5555ddd5ddd5d5d5ddd5ddd5ddd5555dd55ddd5ddd5ddd5ddd5dd555555
5555d5d5d5d55d5555d555555d5d5d5d555d555d555555d5d5d5555d55d5d5d5d5d555555d5d5d555d5d5d555d5d5d5d5555d5d5d5d5ddd5d5d5d555d5d55555
5555d5d5d5d55d555d5555555dd55d5d55d555d5555555d5d5dd555d55d5d5d5d5dd55555dd55dd55d5d5dd55dd55dd55555d5d5ddd5d5d5ddd5dd55d5d55555
5555d5d5d5d55d55d55555555d5d5d5d5d555d55555555d5d5d5555d55d5d5d5d5d555555d5d5d555ddd5d555d5d5d5d5555d5d5d5d5d5d5d555d555d5d55555
5555d5d5dd55ddd5ddd555555ddd55dd5ddd5ddd555555ddd5ddd55d555dd5d5d5ddd5555d5d5ddd55d55ddd5d5d5ddd5555ddd5d5d5d5d5d555ddd5d5d55555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55551111111111111115555551111111111111115555551111111111111111111111155551111111111111111111111155551111111111111111111111155555
55551dddddd111111115555551dddddd1111111155555511111111eeeeee11111111155551dddddd11111111111111115555111111111111111fffffff155555
55551dddddd111111115555551dddddd1111111155555511111111eeeeee11111111155551dddddd11111111111111115555111111111111111fffffff155555
55551dddddd111111115555551dddddd1111111155555511111111eeeeee11111111155551dddddd11111111111111115555111111111111111fffffff155555
55551111111111111115555551111111111111115555551111111111111111111111155551111111111111111111111155551111111111111111111111155555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000101000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0304030403040304030403040304010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040304030403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304050605060304030403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314151615161314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040304030403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040304030403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040304050605060304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314151615161314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040304030403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040304030403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000006160061600215002150011500115003140051300713008130091300b1200611001110231000110001100001000110001100011000110002100021000210002100031000410004100041000410004100
000100000a0400b0300c03012030100300d0300b0500b050030500105000050000500105031300313003130031300313003130031300313003130031300313003130031300313003130030300303002f3002f300
00100000241502f1552f1152e1051b1001c100221002310028100211002910027100291002c100311003210000100001000010000100001000010000100001000010000100001000010000100001000010000100
00100000077050b7040e7020070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000001b12723107000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007
000300001b7202373028752287422871223702217021e7021c7021e702197022f7021c7021d7021f7022370228702287022870228702287022f7022c7022e7023370234702287022c702337021f7020070200702
0003000016030220302f0302f0302c0302c0302f0202f0202c0202c0102f0102f0102f0002c0002c0002f0002f0002c0002c0002f0002f000000000000000000000010b1030c1000000100001000010000100001
00020000386503565033650316502a650226401b64017630126300d62006620016100c6500b6500a6500865007640056400463003620026101a6001b60015600116000d6000960017600146000f6000860003600
911000001d0411d0611d0611d0611d0511d0511d0411d0411d0311d0311d0311d0311d0411d0411d0411d04121041210612106121061210512105121041210412103121031210312103121041210412104121041
3510000018735197051870506705187350c705177051a70518735197051870506705187350c705177051a7051f7351970518705067051f7350c705177051a7051f7351970518705067051f7350c705177051a705
91100000200412006120061200612005120051200412004120031200312003120031200412004120041200411d0411d0611d0611d0611d0411d0411d0311d0311c0411c0611c0611c0611c0411c0411c0311c031
3510000023735197051870506705237350c705177051a70523735197051870506705237350c705177051a70521735197051870506705217350c705177051a7051d7351970518705067051d7350c705177051a705
911000001a0411a0611a0611a0611a0511a0511a0411a0411a0311a0311a0311a0311a0411a0411a0411a0411f0411f0611f0611f0611f0511f0511f0411f0411f0311f0311f0311f0311f0411f0411f0411f041
3510000017735197051870506705177350c705177051a70517735197051870506705177350c705177051a7051f7351970518705067051f7350c705177051a7051f7351970518705067051f7350c705177051a705
911000001e0411e0611e0611e0611e0511e0511e0411e0411e0311e0311e0311e0311e0411e0411e0411e0411d0411d0611d0611d0611d0411d0411d0311d0311c0421c0611c0611c0551c0421c0411c0311c055
3510000023735197051870506705237350c705177051a70523735197051870506705237350c705177051a70521735197051870506705217350c705177051a7051d7350000019705067051d7351d7001d70000000
340800200203002030020000200002000020000200001700030300303001000030000403004030040000400002000020000200002700060300603006030060300203002030020300203000000000000300003000
3510000023735197051870506705237350c705177051a70523735197051870506705237350c705177051a70521735197051870506705217350c705177051a7051d73519705067051d70000000000000000000000
911000001e0411e0611e0611e0611e0511e0511e0411e0411e0311e0311e0311e0311e0411e0411e0411e0411d0411d0611d0611d0611d0411d0411d0311d0311d0421d0611d0611d0551d0421d0411d0311d055
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 08094844
00 0a0b4844
00 0c0d4844
00 0e0f4844
00 08091044
00 0a0b1044
00 0c0d1044
02 11121044

