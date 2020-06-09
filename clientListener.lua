local repStorage = game:GetService("ReplicatedStorage");
local repPlayerDeathRemote = repStorage:WaitForChild("ReplicateDeaths");
local repPlayerFootstepRemote = repStorage:WaitForChild("ReplicateFootsteps");

local bullet = game.ReplicatedStorage:WaitForChild("bullet")
local rayEvent = game.ReplicatedStorage:WaitForChild("ReplicateTrails")

--// Audio \\--

local audio = repStorage:WaitForChild("Audio");
local deathSound = audio:WaitForChild("deathSound");

local players = game.Players:GetPlayers();

local function replaceFootstepSound()

	for i = 1, #players, 1 do
		print(players[i])
		local runningSound = players[i].Character:WaitForChild("HumanoidRootPart").Running;
		runningSound.SoundId = "rbxassetid://2991635108";
		runningSound.PlaybackSpeed = 1.2;
		runningSound.Volume = 0.3;
	end

end

--\\ Audio //--

local function ragdoll(ragdoll, target)
	local ragdollClone = ragdoll:Clone();
	local ragdollChildren = ragdollClone:GetChildren();
	for i = 1, #ragdollChildren, 1 do
		local currentChild = ragdollChildren[i];
		if (currentChild:IsA("MeshPart") or currentChild:IsA("Part")) and target:FindFirstChild(currentChild.Name) ~= nil then
			currentChild.CFrame = target:FindFirstChild(currentChild.Name).CFrame;
		end
	end
	wait(.1)
	target:Destroy();
	ragdollClone.Parent = workspace;
	local deathSoundClone = deathSound:Clone();
	deathSoundClone.Parent = ragdollClone.Head;
	deathSoundClone.PlaybackSpeed = math.random(88, 100)/100;
	deathSoundClone:Play();
end

local function rayEffect(position, muzzle)
	if position ~= nil and muzzle ~= nil then
		local bulletClone = bullet:Clone()
		bulletClone.Parent = workspace
		for i = 1, 50, 1 do
			game:GetService("RunService").Heartbeat:Wait();
			bulletClone.CFrame = CFrame.new(muzzle, position) * CFrame.new(0, 0, -13*i);
		end
		bulletClone:Remove()
	end
end

rayEvent.OnClientEvent:Connect(rayEffect);
repPlayerDeathRemote.OnClientEvent:Connect(ragdoll);
repPlayerFootstepRemote.OnClientEvent:Connect(replaceFootstepSound);