--!strict


--> Services ------------------------------------------------------------------------------------------
local AssetService = game:GetService("AssetService")
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
export type RadialConfig = {
	Size: number,
	Thickness: number?,
	DefaultValue: number?,
	OverlayImageId: number?,
	Ends: "Rounded"?
}
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
local function Magnitude(x1: number, y1: number, x2: number, y2: number)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function GetOverlayImageData(imageId: number, newSize: Vector2)
	local eImage = AssetService:CreateEditableImageAsync(`rbxassetid://{imageId}`)
	eImage:Resize(newSize)
	local eImageSize = eImage.Size
	local pixels = eImage:ReadPixels(Vector2.zero, eImageSize)
	eImage:Destroy()
	return pixels, eImageSize.X, eImageSize.Y
end

local function ReadPixel(pixelArray: { number }, startIndex: number)
	return
		pixelArray[startIndex], pixelArray[startIndex + 1],
		pixelArray[startIndex + 2], pixelArray[startIndex + 3]
end


local function WritePixel(pixelArray: { number }, startIndex: number, r: number, g: number, b: number, a: number)
	pixelArray[startIndex] = r
	pixelArray[startIndex + 1] = g
	pixelArray[startIndex + 2] = b
	pixelArray[startIndex + 3] = a
end

local function DrawRoundedEnd(eImage: EditableImage, center: Vector2, radius: number, overlayImagePixelsArray, overlayImageHeight)
	local topLeft = Vector2.new(center.X - radius, center.Y - radius)
	local diameter = radius * 2
	local eImagePixels = eImage:ReadPixels(topLeft, Vector2.one * diameter)
	
	local pixelsArray = table.create(diameter ^ 2 * 4, 0)
	
	local function writePixelOfCircle(x: number, y: number)
		local adjX, adjY = x - topLeft.X, y - topLeft.Y
		local startIndex = ((adjY * diameter + adjX) * 4) + 1
		
		local mag = Magnitude(x + .5, y + .5, center.X, center.Y)
		
		local _,_,_, underlayAlpha = ReadPixel(eImagePixels, startIndex)
		
		local alpha = (
			mag > radius and 0 or
			((mag > radius - 1)) and -(mag - radius) or
			1
		)
		alpha = math.max(alpha, underlayAlpha)
		
		
		local r, g, b, alphaB
		if overlayImagePixelsArray then
			r, g, b, alphaB = ReadPixel(overlayImagePixelsArray, ((math.floor(y) * overlayImageHeight + math.floor(x)) * 4) + 1)
			alpha = alphaB and math.min(alpha, alphaB) or alpha
		else
			r, g, b = 1, 1, 1
		end
		
		WritePixel(pixelsArray, ((adjY * diameter + adjX) * 4) + 1,  r, g, b, alpha)
	end
	
	for x = 0, diameter - 1 do
		for y = 0, diameter - 1 do
			writePixelOfCircle(topLeft.X + x, topLeft.Y + y)
		end
	end
	
	eImage:WritePixels(topLeft, Vector2.one * diameter, pixelsArray)
end

local function NewRadial(config: RadialConfig)
	local size = config.Size
	local thickness, value, overlayImageId, ends =
		(config.Thickness or (size / 4)) + 1, config.DefaultValue or 28, config.OverlayImageId, config.Ends
	
	local sizeV2 = Vector2.one * size
	local center = size / 2
	
	local eImage = Instance.new("EditableImage")
	eImage.Size = sizeV2
	
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.fromOffset(size, size)
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	
	local overlayImagePixelsArray, overlayImageWidth, overlayImageHeight
	if overlayImageId then overlayImagePixelsArray, overlayImageWidth, overlayImageHeight = GetOverlayImageData(overlayImageId, sizeV2) end
	
	local function drawRadial(progressPercentage: number)
		if progressPercentage == 0 then
			local pixelsArray = table.create(size ^ 2 * 4, 0)
			
			return eImage:WritePixels(Vector2.zero, sizeV2, pixelsArray)
		end
		
		progressPercentage = math.clamp(progressPercentage + .15, 1, 100)
		local angle = 360 * (progressPercentage / 100)
		
		local pixelsArray = table.create(size ^ 2 * 4, 0)
		local weightedCenter = center - thickness
		
		local function writePixelOfRadial(x: number, y: number)
			
			local mag = Magnitude(x + .5, y + .5, center, center)
			if mag > center or mag < weightedCenter then return end
			
			local pixelAngle = (math.deg(math.atan2(y - center, x - center)) + 90) % 360
			if pixelAngle > angle then return end
			
			local alpha = (
				-- Middle Edges smoothing.
				(progressPercentage ~= 100 and ends ~= "Rounded" and pixelAngle > angle - .8) and -(pixelAngle - angle) - .2 or
					
				-- Outside edge smoothing.
				(mag > center - 1) and -(mag - center) or
					
				-- Inside edge smoothing.
				(mag < weightedCenter + 1) and (mag - weightedCenter) or
					
				1
			)
			
			local r, g, b, alphaB
			if overlayImageId then
				r, g, b, alphaB = ReadPixel(overlayImagePixelsArray, ((y * overlayImageHeight + x) * 4) + 1)
				alpha = math.min(alpha, alphaB)
			else
				r, g, b = 1, 1, 1
			end
			
			WritePixel(pixelsArray, ((y * size + x) * 4) + 1, r, g, b, alpha)
		end
		
		for x = 0, size - 1 do
			for y = 0, size - 1 do
				writePixelOfRadial(x, y)
			end
		end

		eImage:WritePixels(Vector2.zero, sizeV2, pixelsArray)
	
		if ends == "Rounded" then
			DrawRoundedEnd(eImage, Vector2.new(center, thickness / 2), thickness / 2, overlayImagePixelsArray, overlayImageHeight)
			
			local angle_radians = math.rad(((angle) - 90) % 360)
			local middle_of_radial = center - thickness / 2
			local x = center + middle_of_radial * math.cos(angle_radians)
			local y = center + middle_of_radial * math.sin(angle_radians)
			
			DrawRoundedEnd(eImage, Vector2.new(x + .6, y + .6), thickness / 2, overlayImagePixelsArray, overlayImageHeight)
		end
	end

	drawRadial(value)
	
	eImage.Parent = imageLabel
	
	return {
		Value = value,
		
		ImageLabel = imageLabel,
		
		Update = function(progressPercentage: number)
			value = progressPercentage
			drawRadial(value)
		end,
		
		Increment = function(incrementBy: number)
			value += incrementBy
			drawRadial(value)
		end,
	}
end
-------------------------------------------------------------------------------------------------------


return {
	new = NewRadial
}
