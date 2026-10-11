local Glowy = {} do
	Glowy.Library = nil
	Glowy.Funcs = nil
	Glowy.Image = 'rbxassetid://76478020447463'
	Glowy.Padding = 0.3
	Glowy.Transparency = 0.4

	function Glowy:SetLibrary(lib)
		self.Library = lib
	end

	function Glowy:Hook(groupbox)
		local Library = self.Library
		local funcs = getmetatable(groupbox).__index

		if self.Funcs == funcs then return end
		self.Funcs = funcs

		for _, name in { 'AddToggle', 'AddSlider', 'AddDropdown', 'AddInput', 'AddButton' } do
			local old = funcs[name]

			funcs[name] = function(box, ...)
				local before = {}
				for _, child in box.Container:GetChildren() do
					before[child] = true
				end

				local obj = old(box, ...)

				local info = select(name == 'AddButton' and 1 or 2, ...)
				local outer
				for _, child in box.Container:GetChildren() do
					if not before[child] and child:IsA('Frame') and child.BackgroundTransparency == 0 then
						outer = child
					end
				end

				if not outer then return obj end

				local glow
				obj.Glow = type(info) == 'table' and info.Glow == true

				local function update()
					if obj.Glow and not glow then
						local pad = math.floor(outer.Size.Y.Offset * Glowy.Padding + 0.5)

						glow = Library:Create('ImageLabel', {
							AnchorPoint = Vector2.new(0.5, 0.5);
							BackgroundTransparency = 1;
							Image = Glowy.Image;
							ImageColor3 = Library.AccentColor;
							ImageTransparency = Glowy.Transparency;
							Position = UDim2.fromScale(0.5, 0.5);
							Size = UDim2.new(1, pad * 2, 1, pad * 2);
							ZIndex = outer.ZIndex - 1;
							Parent = outer;
						})

						Library:AddToRegistry(glow, { ImageColor3 = 'AccentColor'; })
					end

					if glow then
						glow.Visible = obj.Glow and (obj.Type ~= 'Toggle' or obj.Value)
					end
				end

				if obj.Type == 'Toggle' then
					local display = obj.Display

					obj.Display = function(...)
						display(...)
						update()
					end
				end

				function obj:SetGlow(bool)
					self.Glow = bool
					update()
				end

				update()

				return obj
			end
		end
	end
end

return Glowy
