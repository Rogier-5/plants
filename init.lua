-- Must have

--Grow in different terrains for example
--cliffs
--near water
--in open fields far from trees
--in dessert environtments
--beneath trees
--next to stone
--near sand
--near dessert
--in dessert?

--Should do
--Function which gives possibilty to add crops

--A simple farming mod

--mod name

--variable and function definitions
local mod_name = "harvest"

local wild_crops = {}
local wild_crop_count = 0

local function arrayContains(array, value)
    for _,v in pairs(array) do
      if v == value then
        return true
      end
    end
    
    return false
end

local function generate(node, surfaces, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes)
    if maxp.y < height_min or minp.y > height_max then
		return
	end
	
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	
	local width   = maxp.x-minp.x
	local length  = maxp.z-minp.z
	local height  = height_max-height_min
    
    local y_current
	local x_current
	local z_current
	
	local x_deviation
	local z_deviation
	
	--apperently nested while loops don't work!
	for x_current = spread/2, width, spread do
	    for z_current = spread/2, length, spread do

	        x_deviation = math.floor(math.random(spread))-spread/2
	        z_deviation = math.floor(math.random(spread))-spread/2

	        for y_current = height_max, height_min, -1 do
	            --print(x_current .. "-" .. width .. " - " .. x_current)
	            
	            local p = {x=minp.x+x_current+x_deviation, y=y_current, z=minp.z+z_current+z_deviation}
	            local n = minetest.env:get_node(p)
	            
	            local p_top = {x=p.x, y=p.y+1, z=p.z}
	            local n_top = minetest.env:get_node(p_top)
	            if n_top.name == "air" then
	            
                    if arrayContains(surfaces, n.name) then 
                        if minetest.env:find_node_near(p_top, habitat_size, habitat_nodes) ~= nil then
                            print(p.x .. " - " .. p.y .. " - " .. p.z)
                            minetest.env:add_node(p_top, {name=node})
                        end
                    end

	            end
	        end
	        --randomize positioning a little and then check if the surface(grow on) node is beneath it. If so check if habitat node is within the habitat_size. If so create the node.
	        

	        z_current = z_current + spread
        end
    end
end

local add_farm_plant = function(name_plant) --register a farming plant
    
    local name = mod_name..":"..name_plant
    local img = mod_name.."_"..name_plant
    
    
    
    
    minetest.register_node(name.."_wild", {--register wild plant
        tile_images = {img.."_wild.png"},
        drawtype = "plantlike",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        groups = { snappy = 3},
        drop = { items = { name.."_seedling"},
		    max_items = 1,
		    items = {
			    {
				    items = {name.."_seedling"},
				    rarity = 30,
			    },
		    }
	    },
    })
    
    minetest.register_node(name.."_seedling", {--register seedling
        tile_images = {img.."_seedling.png"},
        wield_image = img.."_seeds.png",
        inventory_image = img.."_seeds.png",
        drawtype = "plantlike",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        groups = { snappy = 3},
        drop = "",
    })
    
    minetest.register_node(name.."_sapling", {--register sapling
        tile_images = {img.."_sapling.png"},
        drawtype = "plantlike",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        groups = { snappy = 3},
        drop = "",
    })
    
    minetest.register_node(name.."_plant", {--register plant
        tile_images = {img.."_plant.png"},
        drawtype = "plantlike",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        groups = { snappy = 3},
        drop = "",
    })
    
    minetest.register_node(name.."_harvest", {--register plant
        tile_images = {img.."_harvest.png"},
        drawtype = "plantlike",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        groups = { snappy = 3},
        drop = "",
    })
end

local add_plant = function(name_plant) -- register a wild plant
    
    local name = mod_name..":"..name_plant
    local img = mod_name.."_"..name_plant
    
    minetest.register_node(name.."_wild", {--register wild plant
        tile_images = {img.."_wild.png"},
        inventory_image = img.."_wild.png",
        drawtype = "plantlike",
        sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		groups = { snappy = 3,flammable=2 },
    })
    
end

--plant registration
--Just wild plant
--node registration
--make tools with which dirt can be prepared for growing
minetest.register_tool(mod_name..":hoe_wood", {
	description = "Sickle",
	inventory_image = "harvest_hoe_wood.png",
	on_use = function(itemstack, user, pointed_thing)
        -- Must be pointing to node
		if pointed_thing.type ~= "node" then
			return
		end
		-- Check if pointing to dirt or dirt_with_grass
		n = minetest.env:get_node(pointed_thing.under)
		
		if n.name == "default:dirt" or n.name == "default:dirt_with_grass" then
		    minetest.env:add_node(pointed_thing.under, {name=mod_name..":soil"})
		end
        
        
	end,
})

--Make node in which dirt changes after hoe preperation
minetest.register_node(mod_name..":soil", {
	description = "Soil",
	tile_images = {"harvest_soil.png", "default_dirt.png"},
	groups = {crumbly=3},
	drop = 'default:dirt',
	after_dig_node = function(pos)
	    
	end,
})

--create plant nodes. Not all plants spawn in the wild for this you have to define it on the generate on function
add_farm_plant("cotton")
add_plant("corn")
add_plant("lavender")
add_plant("potato")
add_plant("redshroom")
add_plant("cacao")

--generate(node, surface, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes)
--For the plants that do spawn on the lang we have the generate function. This makes sure that plants are placed when new peaces of the level are loaded.
minetest.register_on_generated(function(minp, maxp, seed)
	generate("harvest:lavender_wild", {"default:dirt_with_grass"}, minp, maxp, -10, 60, 4, 4, {"default:sand",})
	generate("harvest:redshroom_wild", {"default:dirt_with_grass"}, minp, maxp, -10, 60, 20, 8, {"default:leaves",})
	generate("harvest:corn_wild", {"default:dirt_with_grass"}, minp, maxp, -10, 60, 8, 10, {"default:water_source",})
	generate("harvest:cotton_wild", {"default:dirt_with_grass"}, minp, maxp, -10, 60, 8, 10, {"default:desert_sand",})
	
end)

print("[Harvest] Loaded!")
