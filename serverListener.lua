--// Remote Events & Functions \\--

local repStorage = game:GetService("ReplicatedStorage");
local repPlayerDeathRemote = repStorage:WaitForChild("ReplicateDeaths");
local repPlayerFootstepRemote = repStorage:WaitForChild("ReplicateFootsteps");
local repTrainDepart = repStorage:WaitForChild("ReplicateTrainDepart");

local bullet = game.ReplicatedStorage:WaitForChild("bullet")
local rayEvent = game.ReplicatedStorage:WaitForChild("ReplicateTrails")

local gameActive = workspace:WaitForChild("GameActive");

--// Audio \\--

local audio = repStorage:WaitForChild("Audio");
local deathSound = audio:WaitForChild("deathSound");

--// Common References \\--

local players = game.Players:GetPlayers();
local RunService = game:GetService("RunService");

--// Functions \\--

local function replaceFootstepSound()

	for i = 1, #players, 1 do
		--print(players[i])
		if players[i].Character ~= nil and players[i].Character:FindFirstChild("HumanoidRootPart") ~= nil then
				
			local runningSound = players[i].Character:WaitForChild("HumanoidRootPart"):FindFirstChild("Running");
			
			if runningSound then
				runningSound.SoundId = "rbxassetid://2991635108";
				runningSound.PlaybackSpeed = 1.2;
				runningSound.Volume = 1;
			end
			local jumpingSound = players[i].Character:WaitForChild("HumanoidRootPart"):FindFirstChild("Jumping");
			if jumpingSound then
				jumpingSound.SoundId = "rbxassetid://145487017";
				jumpingSound.PlaybackSpeed = .9;
				jumpingSound.Volume = 1;
			end
			
		end
	end

end

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
			bulletClone.CFrame = CFrame.new(muzzle, position) * CFrame.new(0, 0, -16*i);
		end
		bulletClone:Remove()
	end
end

local trainModel = workspace:WaitForChild("de_metro"):WaitForChild("Geometry"):WaitForChild("Metro Train");

local function departTrain()
	--trainModel:WaitForChild("TrainMain"):WaitForChild("DoorsClose"):Play();
	--wait(2);
	trainModel:WaitForChild("TrainMain"):WaitForChild("TrainMove"):Play();
	local stopDelay = 10;
	for i = 10, 20, 0.01 do
		if trainModel:WaitForChild("TrainMain"):WaitForChild("TrainMove").PlaybackSpeed < 3 then
			trainModel:WaitForChild("TrainMain"):WaitForChild("TrainMove").PlaybackSpeed = (math.sqrt(i)) - 2.5;
		end	
		RunService.Heartbeat:Wait();
		trainModel:SetPrimaryPartCFrame(trainModel:WaitForChild("TrainMain").CFrame * CFrame.new(0, 0, -(i * 0.06)^6));
		if gameActive.Value == false then
			stopDelay = stopDelay - .02
			if stopDelay < 1 then
				trainModel:WaitForChild("TrainMain"):WaitForChild("TrainMove"):Stop();
				break;
			end
		end
	end
end

--// Remote Event & Function Listeners \\--

rayEvent.OnClientEvent:Connect(rayEffect);
repPlayerDeathRemote.OnClientEvent:Connect(ragdoll);
repPlayerFootstepRemote.OnClientEvent:Connect(replaceFootstepSound);
repTrainDepart.OnClientEvent:Connect(departTrain)