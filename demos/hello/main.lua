
local font = of.TrueTypeFont()
-- from https://www.babbel.com/en/magazine/how-to-say-hello-in-10-different-languages
local langs = {"Hello", "Guten Tag", "Bonjour", "Hola", "Zdravstvuyte",
               "Ni Hao", "Konnichiwa", "Salve", "Shikamoo", "Namaste",
               "Shalom", "God dag"} 
local hello = {
	text = nil,
	timestamp = {
		check = 0,
		show = 0
	},
	active = false
}
local hand = {
	detected = false,
	spread = 0, -- spread value moving average
	centroid = glm.vec3(0, 0, 0) -- normalized centroid
}

local trail = {
	line = of.Polyline(),
	average = glm.vec3(0, 0, 0),
	diff = glm.vec3(0, 0, 0),
	trigger = {
		count = 0,
		pdirection = 0, -- -1 left, 0 neutral, 1 right
		timestamp = 0,
		points = {},
		clear = function(self)
			self.count = 0
			self.points = {}
			self.pdirection = 0
		end
	}
}
local ddebug = false

function setup()
	of.setWindowTitle("Hello")
	of.background(232)

	font:load(of.TTF_MONO, 48)

	loaf.setListenPort(9999)
	loaf.startListening()
end

function update()
	if hello.active then
		if of.getElapsedTimef() - hello.timestamp.show > 4 then
			-- end
			hello.active = false
			hello.text = randomHello()
			hello.timestamp.check = of.getElapsedTimef()
			trail.trigger:clear()
			trail.average = glm.vec3(0, 0, 0)
			trail.diff = glm.vec3(0, 0, 0)
		end
	--elseif of.getElapsedTimef() - hello.timestamp.check > 2 and hand.spread > 0.7
	elseif hand.spread > 0.7 and trail.trigger.count > 2 then
		-- start
		hello.active = true
		hello.timestamp.show = of.getElapsedTimef()
		hello.text = randomHello()
		trail.trigger:clear()
	end
end

function draw()

	-- gesture debug
	if ddebug and hand.detected then

		-- trail
		of.pushMatrix()
			of.scale(of.getWidth(), of.getHeight())
			of.setColor(0)
			trail.line:draw()
		of.popMatrix()

		-- trigger points
		of.setColor(200, 100, 200)
		for i=1,#trail.trigger.points do
			local p = trail.trigger.points[i]
			of.drawCircle(p.x * of.getWidth(), p.y * of.getHeight(), 5)
		end

		-- trail average
		of.setColor(100, 200, 100)
		of.drawCircle(trail.average.x * of.getWidth(), trail.average.y * of.getHeight(), 8)

		-- centroid
		of.setColor(100, 100, 200)
		of.drawCircle(hand.centroid.x * of.getWidth(), hand.centroid.y * of.getHeight(), 12)
	end

	-- text
	if hello.active then
		of.setColor(64)
		local rect = font:getStringBoundingBox(hello.text, 0, 0)
		font:drawString(hello.text, of.getWidth()/2 - rect.width / 2, of.getHeight()/2 + rect.height/2)
	end
end

function randomHello()
	local index = math.ceil(math.random() * #langs)
	return langs[index]
end

function keyPressed(key)
	if key == string.byte("d") then
		ddebug = not ddebug
	end
end

function oscReceived(message)
	if message:getAddress() == "/detected" then
		hand.detected = message:getArgAsBool(0)
		hand.spread = 0
		trail.line:clear()
	elseif message:getAddress() == "/spread" then
		hand.spread = mavg(hand.spread, message:getArgAsFloat(0), 5)
	elseif message:getAddress() == "/centroid" then

		hand.centroid.x = message:getArgAsFloat(0)
		hand.centroid.y = message:getArgAsFloat(1)
		trail.line:addVertex(hand.centroid)

		local paverage = glm.vec3(trail.average.x, trail.average.y, trail.average.z)
		trail.average.x = mavg(trail.average.x, hand.centroid.x, trail.line:size())
		trail.average.y = mavg(trail.average.y, hand.centroid.y, trail.line:size())
		trail.average.z = mavg(trail.average.z, hand.centroid.z, trail.line:size())

		trail.diff = trail.average - paverage
		if of.getElapsedTimef() - trail.trigger.timestamp > 0.1 and
			math.abs(trail.diff.x) > 0.01 and math.abs(trail.diff.z) < 0.001 and
			math.sign(trail.diff.x) ~= trail.trigger.pdirection then
			trail.trigger.count = trail.trigger.count + 1
			trail.trigger.timestamp = of.getElapsedTimef()
			trail.trigger.pdirection = math.sign(trail.diff.x)
			table.insert(trail.trigger.points, glm.vec3(hand.centroid.x, hand.centroid.y, hand.centroid.z))
		end
	end
end

function mavg(old, new, window)
	return old * ((window - 1) / window) + new * (1 / window)
end

math.sign = function(v)
	return v > 0 and 1 or v < 0 and -1 or 0
end
