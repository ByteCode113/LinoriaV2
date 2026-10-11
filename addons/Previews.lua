local runService = game:GetService('RunService')
local players = game:GetService('Players')

local PreviewManager = {} do
	PreviewManager.Library = nil
	PreviewManager.Previews = {}
	PreviewManager.GridImage = 'rbxassetid://92757644262328'

	function PreviewManager:SetLibrary(lib)
		self.Library = lib
	end

	function PreviewManager:AddPreview(groupbox, idx, info)
		local Library = self.Library
		info = info or {}

		local Preview = {
			Type = 'Preview',
			Model = nil
		}

		local height = info.Height or 200

		local outer = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, height);
			ZIndex = 5;
			Parent = groupbox.Container;
		})

		local inner = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = outer;
		})

		Library:AddToRegistry(outer, { BorderColor3 = 'Black'; })
		Library:AddToRegistry(inner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		})

		--[[
			Grid thingy
		]]
		local grid = Library:Create('ImageLabel', {
			BackgroundTransparency = 1;
			Image = info.GridImage or self.GridImage;
			ImageColor3 = Library.OutlineColor;
			ImageTransparency = 0.5;
			ScaleType = Enum.ScaleType.Crop;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 7;
			Parent = inner;
		})

		Library:AddToRegistry(grid, { ImageColor3 = 'OutlineColor'; })

		local viewport = Library:Create('ViewportFrame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 8;
			Parent = inner;
		})

		local camera = Instance.new('Camera')
		camera.FieldOfView = info.FieldOfView or 40
		camera.Parent = viewport
		viewport.CurrentCamera = camera

		function Preview:SetModel(model)
			if self.Model then
				self.Model:Destroy()
			end

			self.Model = model
			model.Parent = viewport
			model:PivotTo(CFrame.new())

			local cf, size = model:GetBoundingBox()
			local dist = ((size.Y / 2) / math.tan(math.rad(camera.FieldOfView / 2)) + (size.Z / 2)) * 1.2

			camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0, 0, -dist), cf.Position)
		end

		if info.Rotate then
			Library:GiveSignal(runService.RenderStepped:Connect(function(dt)
				if not Preview.Model then return end

				local obj, shown = outer, true
				while obj and obj:IsA('GuiObject') do
					shown = shown and obj.Visible
					obj = obj.Parent
				end

				if shown then
					Preview.Model:PivotTo(Preview.Model:GetPivot() * CFrame.Angles(0, dt * (info.RotateSpeed or 1), 0))
				end
			end))
		end

		if info.Model then
			local clone = info.Model:Clone()
			assert(clone, 'AddPreview: Model is not archivable.')
			Preview:SetModel(clone)
		else
			task.spawn(function()
				local success, rig = pcall(players.CreateHumanoidModelFromDescription, players, Instance.new('HumanoidDescription'), Enum.HumanoidRigType.R15)
				if success and rig and not Preview.Model then
					Preview:SetModel(rig)
				end
			end)
		end
		Preview.Viewport = viewport
		Preview.Inner = inner
		groupbox:AddBlank(info.BlankSize or 5)
		groupbox:Resize()
		self.Previews[idx] = Preview
		return Preview
	end
end

return PreviewManager
