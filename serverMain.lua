local repStorage = game:GetService("ReplicatedStorage");
local bulletHole = repStorage:WaitForChild("bulletHole");
local teams = game:GetService("Teams");
local bloodEffect = repStorage:WaitForChild("BloodEffect");
local bloodSplatter1 = repStorage:WaitForChild("BloodSplatter1");
local bloodSplatter2 = repStorage:WaitForChild("BloodSplatter2");
local bloodSplatter3 = repStorage:WaitForChild("BloodSplatter3");

local readiedPlayers = workspace:WaitForChild("ReadiedPlayers");

--remote events

local repDamageRemote = repStorage:WaitForChild("ReplicateDamage");
local repCharacterRemote = repStorage:WaitForChild("ReplicateCharacters");
local repShotRemote = repStorage:WaitForChild("ReplicateShooting");
local repPlayerDeathRemote = repStorage:WaitForChild("ReplicateDeaths");
local repEquipRemote = repStorage:WaitForChild("ReplicateEquip");
local repReadiedPlayersRemote = repStorage:WaitForChild("ReplicateReadied");
local repInitializeRemote = repStorage:WaitForChild("ReplicateInitialize");
local repEndMatchRemote = repStorage:WaitForChild("ReplicateEndMatch");
local getDataRemote = repStorage:WaitForChild("GetData");
local repIncrementData = repStorage:WaitForChild("IncrementData");
local repFootstepsRemote = repStorage:WaitForChild("ReplicateFootsteps");
local repRaysRemote = repStorage:WaitForChild("ReplicateTrails");
local repGetData = repStorage:WaitForChild("GetData");

local gameActive = workspace:WaitForChild("GameActive");

--// Audio \\--

local audio = repStorage:WaitForChild("Audio");

local rSound = audio:WaitForChild("Reverb");

local bulletHitFleshSound = audio:WaitForChild("hitFlesh1");
local rusVoice = repStorage:WaitForChild("Russian Voicelines");
local usVoice = repStorage:WaitForChild("American Voicelines");

local deathEffect = audio:WaitForChild("deathSound");

--\\ Audio //--

--// DataStore Stuff Start \\--

local DataStoreService = game:GetService("DataStoreService");
local experienceStore = DataStoreService:GetDataStore("PlayerExperience");
local unspentSkillPointsStore = DataStoreService:GetDataStore("UnspentSkillPoints");
local levelStore = DataStoreService:GetDataStore("Level");
local betterPlatesStore = DataStoreService:GetDataStore("betterPlates");
local quickFeetStore = DataStoreService:GetDataStore("quickFeet");
local steadyAimStore = DataStoreService:GetDataStore("steadyAim");
local sleightOfHandStore = DataStoreService:GetDataStore("sleightOfHand")
local enforcerStore = DataStoreService:GetDataStore("enforcer");
local deepPocketsStore = DataStoreService:GetDataStore("deepPockets");
local M870SkillStore = DataStoreService:GetDataStore("M870Skill");
local AK47SkillStore = DataStoreService:GetDataStore("AK47Skill");
local M60SkillStore = DataStoreService:GetDataStore("M60Skill");
local drasticMeasuresStore = DataStoreService:GetDataStore("drasticMeasures");
local guerillaTacticsStore = DataStoreService:GetDataStore("guerillaTactics");
local juggernautStore = DataStoreService:GetDataStore("juggernaut");
local HoneybadgerSkillStore = DataStoreService:GetDataStore("HoneybadgerSkill");
local M4A1SkillStore = DataStoreService:GetDataStore("M4A1Skill");
local M110SkillStore = DataStoreService:GetDataStore("M110Skill");

local function updateSavedData(player, data, value)
	
	local playerKey = "Player_" .. player.UserId
	
	local temp = data;
	
	if data == "Experience" then
		
		temp = experienceStore;
		
	elseif data == "UnspentSkillPoints" then
		
		temp = unspentSkillPointsStore;
		
	elseif data == "Level" then
			
		temp = levelStore;
			
	else
		
		for i = 1, #skillStorage, 1 do
			if skillStorage[i][2] == data then
				temp = skillStorage[i][1];
			end
		end
		
	end
	
	
	local success, temp = pcall(function()
		return temp:IncrementAsync(playerKey, value)
	end)
	
 
	if success then
		--print("New data:", temp)
	else
		--print("failed request")
	end
end

skillStorage = { {betterPlatesStore, "Better Plates"}, {quickFeetStore, "Quick Feet"}, {steadyAimStore, "Steady Aim"}, {sleightOfHandStore, "Sleight of Hand"}, {enforcerStore, "Enforcer"}, {deepPocketsStore, "Deep Pockets"}, {M870SkillStore, "M870"}, {AK47SkillStore, "AK47"}, {M60SkillStore, "M60"}, {drasticMeasuresStore, "Drastic Measures"}, {guerillaTacticsStore, "Guerilla Tactics"}, {juggernautStore, "Juggernaut"}, {HoneybadgerSkillStore, "Honeybadger"}, {M4A1SkillStore, "M4"}, {M110SkillStore, "M110"} };

function getDataRemote(player, data)
	
	local playerKey = "Player_" .. player.UserId
	local temp;
	
	if data == "Experience" then
		
		temp = experienceStore;
		
	elseif data == "UnspentSkillPoints" then
		
		temp = unspentSkillPointsStore;
		
	elseif data == "Level" then
		
		temp = levelStore;
		
	else
		
		for i = 1, #skillStorage, 1 do
			if skillStorage[i][2] == data then
				temp = skillStorage[i][1];
			end
		end
		
	end
	
	local success, result = pcall(function()
		return temp:GetAsync(playerKey) or 0;
	end)
	 
	if success then
		return result;
	end
end

local function setSavedData(player, data, value)
	
	local playerKey = "Player_" .. player.UserId
	
	local success, err = pcall(function()
		data:SetAsync(playerKey, value)
	end)
	 
	if success then
		--print("Success!")
	end
end

game.Players.PlayerAdded:Connect(function(player)
	--local scope = "Player_" .. player.UserId;
	--playerExperience = DataStoreService:GetDataStore("Experience", scope);
	--playerSkills = DataStoreService:GetDataStore("Skills", scope);
	--updateSavedData(game.Players.GriffthouBiff, "Experience", 30);
	print(player.Name .. " has " .. getDataRemote(player, "Experience") .. " xp")
	print(player.Name .. " has ".. getDataRemote(player, "UnspentSkillPoints") .. " available skill points")
	print(player.Name .. " has " .. getDataRemote(player, "Level") .. " levels and needs " .. (getDataRemote(player, "Level")^1.5 * 5) + 10 .. " more xp to level up")
end)

--\\ DataStore Stuff End //--

local function resetSkills()
	for i = 1, #skillStorage, 1 do
		setSavedData(game.Players.GriffthouBiff, skillStorage[i][1], 0)
	end
end

--// Functions Start \\--

local function repCharacters(player, characterModel, hasBetterPlates)
	local characterModelClone = characterModel:Clone();
	player.Character = characterModelClone;
	characterModelClone.Parent = workspace;
	
	local characterCloneHand = characterModelClone:WaitForChild("RightHand");
	
	wait(1)
	
	if hasBetterPlates then
		characterModelClone:WaitForChild("Humanoid").MaxHealth = 115;
		characterModelClone:WaitForChild("Humanoid").Health = 115;
	end
	
	repFootstepsRemote:FireAllClients();
end

local function repEquip(player, characterModel, oldGunModelName, gunModelName) 
	
	if characterModel:FindFirstChild(oldGunModelName .. "") ~= nil then
		characterModel:FindFirstChild(oldGunModelName .. ""):Destroy()--.Parent = game.Lighting;
	end
	local gunModel = game.Lighting:FindFirstChild(gunModelName):Clone();
	gunModel.Parent = characterModel;
	local characterHand = characterModel:FindFirstChild("RightHand");
	gunModel:SetPrimaryPartCFrame(characterHand.CFrame);
	gunModel:FindFirstChild("Handle"):FindFirstChild("HandleToHand").Part1 = characterHand;
	local AnimationTracks = characterModel:FindFirstChild("Humanoid"):GetPlayingAnimationTracks();
	
	for i, track in pairs (AnimationTracks) do
		track:Stop()
	end
	
	characterModel:WaitForChild("Humanoid"):LoadAnimation(characterModel:WaitForChild("Animations"):WaitForChild("hold" .. gunModelName)):Play(); 
end

local function bloodSplatter(hitStart, hitEnd, vicCharacter) -- raycasts past the victim until hits object, then covers object in blood

	local bloodRay = Ray.new(hitStart, (hitEnd - hitStart).unit * 100); -- fix to go from given muzzle position to given camera transformed position, ignore victim character
	local hitPart, hitPos, hitNorm = workspace:FindPartOnRay(bloodRay, vicCharacter, false, true);
	
	local roll = math.random(1, 3);
	local bloodClone;
	
	if roll == 1 then
		bloodClone = bloodSplatter1:Clone();
	elseif roll == 2 then
		bloodClone = bloodSplatter2:Clone();
	elseif roll == 3 then
		bloodClone = bloodSplatter3:Clone();
	end
	
	bloodClone.Parent = workspace;
	bloodClone:WaitForChild("BloodWeld").Part1 = hitPart;
	bloodClone.Anchored = true;
	bloodClone.CFrame = CFrame.new(hitPos, hitPos - hitNorm);
end

local function updateSkillPoints(player)
	local level = getDataRemote(player, "Level");
	
	if level == nil then
		level = 0;
	end
	
	local value = (level^1.5 * 5) + 10;
	if getDataRemote(player, "Experience") > value then
		updateSavedData(player, "Level", 1);
		updateSavedData(player, "UnspentSkillPoints", 1);
		updateSavedData(player, "Experience", value * -1);
	end
end

local function removeFromTable(array, value)
	for i = 1, #array, 1 do
		if array[i] == value then
			table.remove(array, i);
		end
	end
end

local spetsnazPlayers = {};
local marsocPlayers = {};
local readiedPlayerGroup = {};

local function updateMatch(player)
	
	local team = player.Team;
	
	if team == teams:WaitForChild("Spetsnaz") then
		removeFromTable(spetsnazPlayers, player)
	elseif team == teams:WaitForChild("MARSOC") then
		removeFromTable(marsocPlayers, player)
	end
	
	if #spetsnazPlayers <= 0 or #marsocPlayers <= 0 then -- update MARSOCScore and SpetsScore. When one score reaches 4, fire an event to all clients to trigger the function already written.
		readiedPlayers.Value = 0;
		gameActive.Value = false;
		readiedPlayerGroup = {};
		if #spetsnazPlayers < 1 then
			repEndMatchRemote:FireAllClients("MARSOC");
			for _, winningPlayer in ipairs(spetsnazPlayers) do
				updateSavedData(winningPlayer, experienceStore, 15);	
			end
		elseif #marsocPlayers < 1 then
			repEndMatchRemote:FireAllClients("Spetsnaz");
			for _, winningPlayer in ipairs(marsocPlayers) do
				updateSavedData(winningPlayer, experienceStore, 15);	
			end
		end
		
		spetsnazPlayers = {};
		marsocPlayers = {};
		
		for _, p in pairs(game:GetService("Players"):GetPlayers()) do
			updateSkillPoints(p);
		end
	end
	
end

local function ragdoll(victim)
	
	local vicChar = victim.Character;
	local vicHum = vicChar:FindFirstChild("Humanoid");
	
	if vicChar:FindFirstChild("Ragdoll") == nil then
					
		local ragdollBool = Instance.new("BoolValue"); --so 1 kill can't spawn >1 ragdolls
		ragdollBool.Parent = vicChar;
		ragdollBool.Name = "Ragdoll";
		
		vicHum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
					
		repPlayerDeathRemote:FireAllClients(repStorage:FindFirstChild(vicChar.Name .. "Ragdoll"), vicChar);
				
		local deathEffectClone = deathEffect:Clone();
		deathEffectClone.PlaybackSpeed = math.random(90, 110)/100;
		deathEffectClone.Parent = vicChar;
		deathEffectClone:Destroy();
		
		updateMatch(victim);
					
		wait(.5);
					
	end
end

local debounce = 0;

local function repDamage(player, hitPart, damage, position, normal, rayEnd, startPos)
	
	if hitPart == "reset" then -- if a player kills themself condition
		
		print(player.Name .. " died")
		ragdoll(player)
		
	end
		
	if hitPart and hitPart ~= "reset" then
		
		repRaysRemote:FireAllClients(position, startPos);
		
		if hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(hitPart.Parent).Team ~= player.Team then
	
			local vicHum = hitPart.Parent:FindFirstChild("Humanoid");
			local newDamage = damage;
		
			if vicHum then
				
				if hitPart.Name == "Head" or hitPart.Name == "HeadGear" then
					newDamage = newDamage * 3;
				elseif hitPart.Name == "UpperTorso" or hitPart.Name == "TorsoPart" then
					newDamage = newDamage * 1.2;
				else
					newDamage = newDamage * 0.8;
				end
			
				vicHum.Health = vicHum.Health - newDamage;
				
				print(player.Name .. " dealth " .. newDamage .. " damage to " .. game.Players:GetPlayerFromCharacter(hitPart.Parent).Name .. " (" .. vicHum.Health .. "/100)");
				
				local bloodEffectClone = bloodEffect:Clone();
				bloodEffectClone.Position = hitPart.Position;
				bloodEffectClone.Parent = workspace;
				
				local hitFleshClone = bulletHitFleshSound:Clone();
				hitFleshClone.PlaybackSpeed = math.random(90, 110)/100;
				hitFleshClone.Parent = hitPart;
				hitFleshClone:Play();
				
				bloodSplatter(position, rayEnd, hitPart.Parent);
				
				if vicHum.Health <= 0 then
					
					--ragdoll(hitPart.Parent);
					
					wait(0.5);
					
					local voiceClone;
					
					if player.Team == teams:WaitForChild("Spetsnaz") then
						voiceClone = rusVoice:WaitForChild("enemyDown"):Clone();
					elseif player.Team == teams:WaitForChild("MARSOC") then
						voiceClone = usVoice:WaitForChild("enemyDown" .. math.random(1, 2)):Clone();
					end
					
					--voiceClone.Parent = player.Character;
					--voiceClone.PlaybackSpeed = math.random(95, 105)/100;
					--voiceClone:Play();
					
					updateSavedData(player, experienceStore, 5);	
					
					wait(2);
					
					voiceClone:Destroy();
					
				elseif hitPart.Parent.Name ~= "Spetsnaz1Ragdoll" and hitPart.Parent.Name ~= "MARSOC1Ragdoll" then
					
					if math.random(1, 2) == 1 then
						local flinchAnim1 = vicHum:LoadAnimation(hitPart.Parent.Animations.flinch1);
						flinchAnim1:Play()
					else
						local flinchAnim2 = vicHum:LoadAnimation(hitPart.Parent.Animations.flinch2);
						flinchAnim2:Play()
					end
					
				end
				
			end
			
		elseif hitPart then
			
			local bHClone = bulletHole:Clone();
			
			bHClone.Parent = hitPart;
			bHClone.Anchored = true;
			bHClone.CFrame = CFrame.new(position, position - normal);
		end
		
		return;
	end
end

local muzzleFlashDebounce = false;

local function repShot(player, serverGun)
	if serverGun then
		local fSoundClone = serverGun.FX.Fire:Clone();
		fSoundClone.Parent = player.Character:WaitForChild("Head");
		--fSoundClone.PlaybackSpeed = math.random(90, 100)/100;
		fSoundClone:Play();
		
		local rSoundClone = rSound:Clone();
		rSoundClone.Parent = player.Character:WaitForChild("Head");
		rSoundClone:Play();
		
		local muzzle = serverGun:FindFirstChild("FirePart");
		
		if muzzle and muzzleFlashDebounce == false then
			
			muzzleFlashDebounce = true;
			
			local muzzleFX = muzzle:GetChildren();
		
			for i = 1, #muzzleFX do
				muzzleFX[i].Enabled = true;
			end
			
			muzzleFlashDebounce = false;
		
		else
			print("no muzzle") -- debugging
		end
		
		wait(.1)
		
		if muzzle and muzzleFlashDebounce == false then
			
			local muzzleFX = muzzle:GetChildren();
		
			for i = 1, #muzzleFX do
				muzzleFX[i].Enabled = false;
			end
		
		end
		
		wait(1)
		fSoundClone:Destroy();
	end
end

local function repCheckStart(player)
	
	readiedPlayers.Value = readiedPlayers.Value + 1;
	table.insert(readiedPlayerGroup, player);
	if readiedPlayers.Value >= 2 and gameActive.Value == false then
		gameActive.Value = true;
		wait(5)
		for _, tablePlayer in ipairs(readiedPlayerGroup) do
			if tablePlayer.Team == teams:WaitForChild("Spetsnaz") then
				table.insert(spetsnazPlayers, tablePlayer);
			elseif tablePlayer.Team == teams:WaitForChild("MARSOC") then
				table.insert(marsocPlayers, tablePlayer);
			end
			repInitializeRemote:FireClient(tablePlayer);
		end
		print("spetsnaz players:")
		for i = 1, #spetsnazPlayers, 1 do
			print(spetsnazPlayers[i]);
		end
		print()
		print("marsoc players:")
		for i = 1, #marsocPlayers, 1 do
			print(marsocPlayers[i]);
		end
		print()
	end
end

repDamageRemote.OnServerEvent:Connect(repDamage);
repCharacterRemote.OnServerEvent:Connect(repCharacters);
repShotRemote.OnServerEvent:Connect(repShot);
repEquipRemote.OnServerEvent:Connect(repEquip);
repReadiedPlayersRemote.OnServerEvent:Connect(repCheckStart);
repIncrementData.OnServerEvent:Connect(updateSavedData);
repGetData.OnServerInvoke = getDataRemote;

wait(3)

--resetSkills()