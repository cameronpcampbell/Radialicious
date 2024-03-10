# Radial Progress Bars For Roblox.

NOTE: Requires `EditableMesh` and will only work in Studio at the moment.

## Example Usage
```lua
local Radialicious = require(path.to.radialicious.here)

local MyRadialLoader = Radialicious.new {
	Size = 200, -- number: The size (in pixels) of the radial loader.
	Thickness = 15, -- number: The thickness (in pixels) of the radial loader (set the thickness to `Size / 2` for a pie chart effect).
	DefaultValue = 25, -- number: The default value/progress of the loader,
	OverlayImageId = 10890456172, -- number: [OPTIONAL] The ID of the image to overlay on top of the radial loader.
	Ends = "Rounded" -- "Rounded": [OPTIONAL] If set to `Rounded` then both ends of the radial loader will be rounded.
}

MyRadialLoader.Update(65) -- Updates the value/progress of the radial loader.
```
