-- Kwak Demo
-- Copyright (c) 2021 Dan Wilcox

----- Frog -----

local Frog = class()

function Frog:__init(x, y)
	self.pos = glm.vec2(x, y)
	self.colors = {
		head = of.Color(50, 200, 50),
		mouth = of.Color(50, 100, 75)
	}
	self.animation = {
		mouth = {
			run = false,
			step = 0.1,
			sine = 0
		}
	}
	self.mouth = 0
	self.timestamp = 0
end

function Frog:update()

	-- mouth animation
	local animate = self.animation.mouth
	if animate.run then
		self.mouth = math.sin(animate.sine)
		animate.sine = animate.sine + animate.step
		if animate.sine >= math.pi then
			animate.run = false
			animate.sine = 0
			self.mouth = 0
		end
	end

end

function Frog:draw()
	of.pushMatrix()
	of.translate(self.pos.x, self.pos.y)

	-- head
	of.setColor(self.colors.head)
	of.drawRectangle(0, 0, 200, 100)

	-- mouth
	of.setColor(self.colors.mouth)
	of.drawRectangle(50, 50, 100, self.mouth * 50)

	-- left eye
	of.setColor(255)
	of.drawRectangle(25, -50, 50, 50)

	-- right eye
	of.setColor(255)
	of.drawRectangle(125, -50, 50, 50)

	-- pupils
	of.setColor(0)
	of.drawRectangle(35, -25, 30, 25)
	of.drawRectangle(135, -25, 30, 25)

	of.popMatrix()
end

function Frog:trigger()
	self.animation.mouth.run = true
end

function Frog:set(v)
	self.mouth = of.clamp(v, 0, 1)
end

----- main -----

local frogs = {
	Frog(80, 60),
	Frog(360, 60),
	Frog(220, 240)
}

frogs[2].colors.head = of.Color(200, 200, 50)
frogs[2].colors.mouth = of.Color(100, 100, 25)

frogs[3].colors.head = of.Color(200, 50, 200)
frogs[3].colors.mouth = of.Color(100, 25, 100)

local size = {
	w = 640,
	h = 360
}
local scale = {w = of.getWidth() / size.w, h = of.getHeight() / size.h}
local mode = 0

function setup()
	of.setWindowShape(size.w, size.h)
	of.setWindowTitle("Kwak")
	of.background(of.Color.aqua)

	loaf.setListenPort(8888)
	loaf.startListening()

	loaf.setSendHost("localhost")
	loaf.setSendPort(9999)
	loaf.send("/mode", mode)
end

function update()
	for i=1,#frogs do
		frogs[i]:update()
	end
end

function draw()
	of.pushMatrix()
	of.scale(scale.w, scale.h)
	for i=1,#frogs do
		frogs[i]:draw()
	end
	of.popMatrix()
end

function keyPressed(key)
	if key == 32 then
		mode = (mode ~= 0 and 0 or 1)
		loaf.send("/mode", mode)
	elseif key == 49 then
		frogs[1]:trigger()
	elseif key == 50 then
		frogs[2]:trigger()
	elseif key == 51 then
		frogs[3]:trigger()
	end
end

function windowResized(w, h)
	scale.w = w / size.w
	scale.h = h / size.h
end

function oscReceived(message)
	if message:getAddress() == "/one" then
		frogs[1]:trigger()
	elseif message:getAddress() == "/two" then
		frogs[2]:trigger()
	elseif message:getAddress() == "/three" then
		frogs[3]:set(message:getArgAsFloat(0))
	end
end
