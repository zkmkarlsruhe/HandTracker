-- Hello Demo
-- Copyright (c) 2021 Dan Wilcox

----- Hello -----

local Hello = class()

-- default font
Hello.font = of.TrueTypeFont()

-- active duration in seconds
Hello.duration = 2

-- from https://www.babbel.com/en/magazine/how-to-say-hello-in-10-different-languages
Hello.langs = {
	"Hello", "Guten Tag", "Bonjour", "Hola", "Zdravstvuyte", "Ni Hao",
	"Konnichiwa", "Salve", "Shikamoo", "Namaste", "Shalom", "God Dag"
}

function Hello:__init()
	self.font = Hello.font
	self.text = ""         -- greeting text
	self.active = false    -- is text active (showing?)
	self.timestamp = 0     -- last active timestamp in seconds
	if not self.font:isLoaded() then
		self.font:load(of.TTF_MONO, 48)
	end
end

-- return true if going inactive
function Hello:update()
	if self.active and of.getElapsedTimef() - self.timestamp > Hello.duration then
		return true
	end
	return false
end

function Hello:draw()
	if self.active then
		of.setColor(64)
		local rect = self.font:getStringBoundingBox(self.text, 0, 0)
		self.font:drawString(self.text, of.getWidth()/2 - rect.width / 2, of.getHeight()/2 + rect.height/2)
	end
end

function Hello:show()
	self.active = true
	self.timestamp = of.getElapsedTimef()
end

function Hello:hide()
	self.active = false
end

function Hello:randomize()
	local index = math.ceil(math.random() * #Hello.langs)
	self.text = Hello.langs[index]
end

----- Hand -----

local Hand = class()

function Hand:__init()
	self.detected = false
	self.spread = 0                   -- spread value moving average
	self.centroid = glm.vec3(0, 0, 0) -- normalized centroid
end

function Hand:clear()
	self.detected = false
	self.spread = 0
	self.centroid = glm.vec3(0, 0, 0)
end

function Hand:drawCentroid()
	of.setColor(100, 100, 200)
	of.drawCircle(self.centroid.x * of.getWidth(), self.centroid.y * of.getHeight(), 12)
end

----- Trail -----

local Trail = class()

function Trail:__init()
	self.line = of.Polyline() -- trail path
	self.position = glm.vec3(0, 0, 0) -- average normalized position
	self.velocity = glm.vec3(0, 0, 0) -- average normalized velocity
end

function Trail:add(point)
	self.line:addVertex(point)

	-- averaged position
	local pposition = glm.vec3(self.position)
	self.position.x = math.mavg(self.position.x, point.x, self.line:size())
	self.position.y = math.mavg(self.position.y, point.y, self.line:size())
	self.position.z = math.mavg(self.position.z, point.z, self.line:size())

	-- velocity
	self.velocity = self.position - pposition
end

function Trail:clear()
	self.line:clear()
	self.position = glm.vec3(0, 0, 0)
	self.velocity = glm.vec3(0, 0, 0)
end

function Trail:update()
end

function Trail:draw()
	of.pushMatrix()
		of.scale(of.getWidth(), of.getHeight())
		of.setColor(0)
		self.line:draw()
	of.popMatrix()
end

function Trail:drawPosition()
	of.setColor(100, 200, 100)
	of.drawCircle(self.position.x * of.getWidth(), self.position.y * of.getHeight(), 8)
end

----- Wave -----

-- simple wave gesture detector
local Wave = class()

-- hand spread threshold
Wave.spread = 0.7

-- trail velocity thresholds
Wave.velocity = {
	x = 0.005, -- greater than
	y = 0.005 -- less than
}

-- count threshold
Wave.count = 3

function Wave:__init()
	self.detected = false
	self.count = 0     -- trigger count
	self.direction = 0 -- last trigger direction: -1 left, 0 neutral, 1 right
	self.points = {}   -- trigger points
end

function Wave:clear()
	self.count = 0
	self.direction = 0
	self.points = {}
	self.detected = false
end

function Wave:update(hand, trail)

	-- direction trigger from velocity
	if math.abs(trail.velocity.x) >= Wave.velocity.x and
	   math.abs(trail.velocity.y) <= Wave.velocity.y and
	   math.sign(trail.velocity.x) ~= self.direction then
		self.count = self.count + 1
		self.direction = math.sign(trail.velocity.x)
		self.velocity = glm.vec3(trail.velocity)
		table.insert(self.points, glm.vec3(hand.centroid))
	end

	-- gesture
	if not self.detected and hand.spread >= Wave.spread and self.count >= Wave.count then
		self.detected = true
	end
end

function Wave:drawPoints()
	of.setColor(200, 100, 200)
	for i=1,#self.points do
		local p = self.points[i]
		of.drawCircle(p.x * of.getWidth(), p.y * of.getHeight(), 5)
	end
end

function Wave:directionString()
	return self.direction == -1 and "left" or
		   self.direction == 1 and "right" or
		   "none"
end

----- main -----

local hello = Hello()
local hand = Hand()
local trail = Trail()
local wave = Wave()
local ddebug = true

function setup()
	of.setWindowTitle("Hello")
	of.background(232)

	loaf.setListenPort(9999)
	loaf.startListening()
end

function update()
	if hello.active then
		if hello:update() then
			-- end
			hello:hide()
			trail:clear()
			wave:clear()
		end
	elseif wave.detected then
		-- start
		wave:clear()
		hello:randomize()
		hello:show()
	end
end

function draw()

	-- gesture debug
	if ddebug and hand.detected then
		trail:draw()
		wave:drawPoints()
		trail:drawPosition()
		hand:drawCentroid()
	end

	-- text
	hello:draw()

	-- gesture debug
	if ddebug then
		of.setColor(0)
		of.drawBitmapString("waves: "..wave.count, 6, 12)
		of.drawBitmapString("direction: ", 6, 24)
		of.drawBitmapString("velocity: "..string.format("%.4f %.4f", trail.velocity.x, trail.velocity.y), 6, 36)
		of.setColor(200, 100, 200)
		of.drawBitmapString(wave:directionString(), 90, 24)
	end
end

function keyPressed(key)
	if key == string.byte("d") then
		ddebug = not ddebug
	end
end

function oscReceived(message)
	if message:getAddress() == "/detected" then
		hand.detected = message:getArgAsBool(0)
		if not hand.detected then
			hand:clear()
			trail:clear()
			wave:clear()
		end
	elseif message:getAddress() == "/spread" then
		hand.spread = math.mavg(hand.spread, message:getArgAsFloat(0), 5)
	elseif message:getAddress() == "/centroid" then
		hand.centroid.x = message:getArgAsFloat(0)
		hand.centroid.y = message:getArgAsFloat(1)
		if not hello.active then
			trail:add(hand.centroid)
			wave:update(hand, trail)
		end
	end
end

----- math helpers -----

-- moving average
math.mavg = function(old, new, window)
	return old * ((window - 1) / window) + new * (1 / window)
end

-- return sign of v: -1 negative, 0, 1 positive
math.sign = function(v)
	return v > 0 and 1 or v < 0 and -1 or 0
end
