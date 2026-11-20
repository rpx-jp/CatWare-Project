return function(CatWare)
	local Theme = CatWare.Theme
	local sectionFn = CatWare.Import("src/gui/main/components/section.lua")
	local buttonFn = CatWare.Import("src/gui/main/components/button.lua")
	local toggleFn = CatWare.Import("src/gui/main/components/toggle.lua")
	local sliderFn = CatWare.Import("src/gui/main/components/slider.lua")

	return {
		Section = function(parent, text, theme)
			return sectionFn(parent, text, theme or Theme)
		end,
		Button = function(parent, text, subtext, isDanger, theme, callback)
			return buttonFn(parent, text, subtext, isDanger, theme or Theme, callback)
		end,
		Toggle = function(parent, text, default, theme, callback)
			return toggleFn(parent, text, default, theme or Theme, callback)
		end,
		Slider = function(parent, text, minVal, maxVal, defaultVal, step, suffix, theme, trackConn, callback)
			return sliderFn(parent, text, minVal, maxVal, defaultVal, step, suffix, theme or Theme, trackConn, callback)
		end,
	}
end