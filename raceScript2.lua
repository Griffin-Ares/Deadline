local function repShot(player, serverGun)
	if serverGun then
		local fSoundClone = serverGun.FX.Fire:Clone();
		fSoundClone.Parent = player.Character:WaitForChild("Head");
		--fSoundClone.PlaybackSpeed = math.random(90, 100)/100;
		fSoundClone:Play();
		
		local muzzle = serverGun:FindFirstChild("FirePart");
		
		if muzzle then
			
			local muzzleFX = muzzle:GetChildren();
		
			for i = 1, #muzzleFX - 1 do
				muzzleFX[i].Enabled = true;
			end
		
		end
		
		wait(0.1)
		
		if muzzle then
			
			local muzzleFX = muzzle:GetChildren();
		
			for i = 1, #muzzleFX - 1 do
				muzzleFX[i].Enabled = false;
			end
		
		end
		
		wait(1)
		fSoundClone:Destroy();
	end
end