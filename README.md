# Radial Progress Bars For Roblox.

NOTE: Requires `EditableImage` and will only work in Studio at the moment.

https://github.com/user-attachments/assets/770dc1d9-2063-4e1d-9aed-7d00e6e60ca6
	
<details>
<summary>More Examples</summary>

https://github.com/user-attachments/assets/643887c0-0fe7-4956-b02c-5a765be7db9a

https://github.com/user-attachments/assets/8f7f9630-e46f-481c-b29f-8ddf0de108f6

</details>

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

local ScreenGui = path.to.screengui.here
MyRadialLoader.ImageLabel.Parent = ScreenGui


MyRadialLoader.Update(65) -- Updates the value/progress of the radial loader.
```
