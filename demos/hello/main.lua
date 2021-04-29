
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
	spread = 0 -- spread value moving average
}

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
		end
	elseif of.getElapsedTimef() - hello.timestamp.check > 2 and hand.spread > 0.7 then
		-- start
		hello.active = true
		hello.timestamp.show = of.getElapsedTimef()
		hello.text = randomHello()
	end
end

function draw()
	if hello.active then
		of.setColor(64)
		local rect = font:getStringBoundingBox(hello.text, 0, 0)
		font:drawString(hello.text, of.getWidth()/2 - rect.width / 2, of.getHeight()/2 + rect.height/2)
	end
	of.setColor(0)
	if hand.detected then
		of.drawBitmapString(hand.spread, 10, 10)
	end
end

function randomHello()
	local index = math.floor(math.random() * #langs)
	return langs[index]
end

function oscReceived(message)
	--print(message)
	if message:getAddress() == "/detected" then
		hand.detected = message:getArgAsBool(0)
		hand.spread = 0
	elseif message:getAddress() == "/spread" then
		-- moving average with window size of 5
		hand.spread = hand.spread * 0.8 + message:getArgAsFloat(0) * 0.2
	end
end

