local repStorage = game:GetService("ReplicatedStorage");

local MarketplaceService = game:GetService("MarketplaceService");
local debris = game:GetService("Debris");
local teams = game:GetService("Teams");

local bulletHole = repStorage:WaitForChild("bulletHole");
local bloodEffect = repStorage:WaitForChild("BloodEffect");
local bloodSplatter1 = repStorage:WaitForChild("BloodSplatter1");
local bloodSplatter2 = repStorage:WaitForChild("BloodSplatter2");
local bloodSplatter3 = repStorage:WaitForChild("BloodSplatter3");
local bloodSplatter4 = repStorage:WaitForChild("BloodSplatter4");

local destructableWindow1 = repStorage:WaitForChild("DestructableWindow1");

local readiedPlayers = workspace:WaitForChild("ReadiedPlayers");

local marsocScore = workspace:WaitForChild("MARSOCScore");
local spetsnazScore = workspace:WaitForChild("SpetsScore");

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
local repTrainDepartRemote = repStorage:WaitForChild("ReplicateTrainDepart");
local callTrainDepartRemote = repStorage:WaitForChild("CallTrainDepart");
local updateKillFeedRemote = repStorage:WaitForChild("UpdateKillFeed");

local gameActive = workspace:WaitForChild("GameActive");

--// Audio \\--

local audio = repStorage:WaitForChild("Audio");

local bulletHitFleshSound = audio:WaitForChild("hitFlesh3");
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
local MP7SkillStore = DataStoreService:GetDataStore("MP7Skill");
local M4A1SkillStore = DataStoreService:GetDataStore("M4A1Skill");
local M249SkillStore = DataStoreService:GetDataStore("M249Skill");

--// Functions \\--

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

skillStorage = { {betterPlatesStore, "Better Plates"}, {quickFeetStore, "Quick Feet"}, {steadyAimStore, "Steady Aim"}, {sleightOfHandStore, "Sleight of Hand"}, {enforcerStore, "Enforcer"}, {deepPocketsStore, "Deep Pockets"}, {M870SkillStore, "M870"}, {AK47SkillStore, "AK47"}, {M60SkillStore, "M60"}, {drasticMeasuresStore, "Drastic Measures"}, {guerillaTacticsStore, "Guerilla Tactics"}, {juggernautStore, "Juggernaut"}, {MP7SkillStore, "MP7"}, {M4A1SkillStore, "M4"}, {M249SkillStore, "M249"} };

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
	print(player.Name .. " has " .. getDataRemote(player, "Level") .. " levels and needs " .. ((getDataRemote(player, "Level")^1.5 * 5) + 10) - getDataRemote(player, "Experience") .. " more xp to level up")
	--if player.Name == "gggggghhhhhh678" or player.Name == "PixlKid24" then
	--	updateSavedData(player, unspentSkillPointsStore, 5);	
	--end
end)

--\\ DataStore Stuff End //--

local function resetSkills()
	for i = 1, #skillStorage, 1 do
		setSavedData(game.Players.GriffthouBiff, skillStorage[i][1], 0)
	end
end

--// Functions Start \\--

local SpecialMarsoc1ID = 11185504;

local function ownsGamepass(playerid, gamepassid)
		local ownsGamepass = MarketplaceService:UserOwnsGamePassAsync(playerid, gamepassid);
		if ownsGamepass then
			return true;
		else
			return false;
		end
	end

local function repCharacters(player, characterModel, hasBetterPlates, hasJuggernaut)
	
	local customCharacterModel = characterModel;
	
	if ownsGamepass(player.UserId, SpecialMarsoc1ID) == true and player.Team.Name == "MARSOC" then
		customCharacterModel = repStorage:WaitForChild(player.Team.Name.."1Special");
		print("Switching to custom marsoc model");
	end
	
	local characterModelClone = customCharacterModel:Clone();
	player.Character = characterModelClone;
	characterModelClone.Parent = workspace;
	
	local characterCloneHand = characterModelClone:WaitForChild("RightHand");
	
	wait(1)
	
	if hasBetterPlates then
		characterModelClone:WaitForChild("Humanoid").MaxHealth = 115;
		characterModelClone:WaitForChild("Humanoid").Health = 115;
		if hasJuggernaut then
			characterModelClone:WaitForChild("Humanoid").MaxHealth = 125;
			characterModelClone:WaitForChild("Humanoid").Health = 125;
		end
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
	
	local roll = math.random(1, 4);
	local bloodClone;
	
	if roll == 1 then
		bloodClone = bloodSplatter1:Clone();
	elseif roll == 2 then
		bloodClone = bloodSplatter2:Clone();
	elseif roll == 3 then
		bloodClone = bloodSplatter3:Clone();
	elseif roll == 4 then
		bloodClone = bloodSplatter4:Clone();
	end
	
	bloodClone.Parent = workspace;
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

local function combineArrays(array1, array2)
	local newArray = array1;
	for i = 1, #array2, 1 do
		newArray[#array1 + i] = array2[i];
	end
	return newArray;
end

local spetsnazPlayers = {};
local marsocPlayers = {};
local readiedPlayerGroup = {};
local activePlayers = {};

local function updateMatch(player)
	
	if player ~= "Extracted" then
	
		local team = player.Team;
		
		if gameActive.Value == true then
			if team == teams:WaitForChild("Spetsnaz") then
				removeFromTable(spetsnazPlayers, player)
			elseif team == teams:WaitForChild("MARSOC") then
				removeFromTable(marsocPlayers, player)
			end
		end
	end
		
	if #spetsnazPlayers <= 0 or #marsocPlayers <= 0 or player == "Extracted" and gameActive.Value == true then -- update MARSOCScore and SpetsScore. When one score reaches 4, fire an event to all clients to trigger the function already written.
		readiedPlayers.Value = 0;
		gameActive.Value = false;
		
		if #spetsnazPlayers < 1 or player == "Extracted" then
			marsocScore.Value = marsocScore.Value + 1;
		elseif #marsocPlayers < 1 then
			spetsnazScore.Value = spetsnazScore.Value + 1;	
		end
		
		for _, activePlayer in ipairs(activePlayers) do
			if #spetsnazPlayers < 1 or player == "Extracted" then
				repEndMatchRemote:FireClient(activePlayer, "MARSOC");
			elseif #marsocPlayers < 1 then
				repEndMatchRemote:FireClient(activePlayer, "Spetsnaz");
			end
		end
		
		if #spetsnazPlayers < 1 or player == "Extracted" then
			for _, winningPlayer in ipairs(marsocPlayers) do
				updateSavedData(winningPlayer, experienceStore, 60);	
			end
		elseif #marsocPlayers < 1 then
			for _, winningPlayer in ipairs(spetsnazPlayers) do
				updateSavedData(winningPlayer, experienceStore, 60);	
			end
		end
		
		spetsnazPlayers = {};
		marsocPlayers = {};
		--local newWindow = destructableWindow1:Clone();
		--newWindow.Parent = workspace;
		
		wait(6)
		
		if marsocScore.Value > 2 or spetsnazScore.Value > 2 then
			marsocScore.Value = 0;
			spetsnazScore.Value = 0;
		end
		
		for _, p in pairs(game:GetService("Players"):GetPlayers()) do
			updateSkillPoints(p);
		end
	end
	
end

local function ragdoll(victim, killer)
	
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
		
		updateMatch(victim, killer);
					
	end
	
end

local debounce = 0;
local fleshSoundDebounce = false;
local killFeedDebounce = false;

local function repDamage(player, hitPart, damage, position, normal, rayEnd, startPos)
	
	if hitPart == "reset" then -- if a player kills themself condition
		
		ragdoll(player);
		
	end
		
	if hitPart and hitPart ~= "reset" then
		
		if hitPart.Name == "DestructableWindow1" then
			hitPart:WaitForChild("WindowHealth").Value = hitPart:WaitForChild("WindowHealth").Value -1;
			
			if hitPart:WaitForChild("WindowHealth").Value <= 0 then
				hitPart:Destroy();
			elseif hitPart:WaitForChild("WindowHealth").Value <= 2 then
				hitPart:WaitForChild("windowBrokenRight").Transparency = 0.2;
				hitPart:WaitForChild("windowBrokenLeft").Transparency = 0.2;
			end
		end
		
		repRaysRemote:FireAllClients(position, startPos);
		
		if hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(hitPart.Parent).Team ~= player.Team then
	
			local vicHum = hitPart.Parent:FindFirstChild("Humanoid");
		
			if vicHum then
				
				vicHum.Health = vicHum.Health - damage;
				
				print(player.Name .. " dealt " .. damage .. " damage to " .. game.Players:GetPlayerFromCharacter(hitPart.Parent).Name .. " (" .. vicHum.Health .. "/" .. vicHum.MaxHealth .. ")");
				
				local bloodEffectClone = bloodEffect:Clone();
				bloodEffectClone.Position = hitPart.Position;
				bloodEffectClone.Parent = workspace;
				
				if fleshSoundDebounce == false then
					
					fleshSoundDebounce = true;
						
					local hitFleshClone = bulletHitFleshSound:Clone();
					hitFleshClone.PlaybackSpeed = math.random(90, 110)/100;
					hitFleshClone.Parent = hitPart;
					hitFleshClone:Play();
					
				end
					
				bloodSplatter(position, rayEnd, hitPart.Parent);
				
				if vicHum.Health <= 0 then
					
					local ragdollPart = game.Workspace:WaitForChild("Part");
					local Attachment = Instance.new("Attachment", ragdollPart);
					local Force = Instance.new("VectorForce", game.Workspace);
					Force.Attachment0 = Attachment;
					Force.Force = Vector3.new(1100, 0, 0);
					
					if hitPart.Parent:FindFirstChild("Ragdoll") == nil then
						
						if killFeedDebounce == false then
							killFeedDebounce = true;
							updateKillFeedRemote:FireAllClients(player.Name, game.Players:GetPlayerFromCharacter(hitPart.Parent).Name, player.Team)
						end
					
						wait(0.5);
						
						killFeedDebounce = false;
						
						local voiceClone;
						
						if player.Team == teams:WaitForChild("Spetsnaz") then
							voiceClone = rusVoice:WaitForChild("enemyDown"):Clone();
						elseif player.Team == teams:WaitForChild("MARSOC") then
							voiceClone = usVoice:WaitForChild("enemyDown" .. math.random(1, 2)):Clone();
						end
						
						voiceClone.Parent = player.Character;
						voiceClone:Play();
						
						debris:AddItem(voiceClone, 4);
						
					end
						
					--updateSavedData(player, experienceStore, 5);	
					
					wait(0.25)
					
					fleshSoundDebounce = false;
					
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

game:GetService("Players").PlayerRemoving:Connect(function(player)
	updateMatch(player);
end)

local muzzleFlashDebounce = false;

local function repShot(player, serverGun)
	if serverGun then
		local fSoundClone = serverGun.FX.Fire:Clone();
		fSoundClone.Parent = player.Character:WaitForChild("Head");
		--fSoundClone.PlaybackSpeed = math.random(90, 100)/100;
		fSoundClone:Play();
		
		local muzzle = serverGun:FindFirstChild("FirePart");
		
		if muzzle ~= nil and muzzleFlashDebounce == false then
			
			muzzleFlashDebounce = true;
			
			local muzzleFX = muzzle:GetChildren();
			
			if #muzzleFX < 1 then
				return;
			end
			
			for i = 1, #muzzleFX do
				--if (muzzleFX:IsA("ParticleEmitter") or muzzleFX:IsA("PointLight")) then
					muzzleFX[i].Enabled = true;
				--end
			end
			
			wait(0.2)
		
			for i = 1, #muzzleFX do
				muzzleFX[i].Enabled = false;
			end
			
			muzzleFlashDebounce = false;

		end
		
		wait(1.5)
		fSoundClone:Destroy();
	end
end

local pos1 = workspace:WaitForChild("de_metro"):WaitForChild("Geometry"):WaitForChild("Metro Train"):WaitForChild("pos1");
local trainModel = workspace:WaitForChild("de_metro"):WaitForChild("Geometry"):WaitForChild("Metro Train");
local trainMain = trainModel:WaitForChild("TrainMain");
local defaultTrainPosition = trainMain.CFrame;

local function repCheckStart(player)
	
	readiedPlayers.Value = readiedPlayers.Value + 1;
	table.insert(readiedPlayerGroup, player);
	print("Player ".. player.Name .." joined the queue on the server, " .. #readiedPlayerGroup .. " players ready")
	if readiedPlayers.Value >= 2 and gameActive.Value == false then
		gameActive.Value = true;
		wait(5)
		for _, tablePlayer in ipairs(readiedPlayerGroup) do
			
			if tablePlayer.Team == nil then
				if #teams:WaitForChild("MARSOC"):GetPlayers() > #teams:WaitForChild("Spetsnaz"):GetPlayers() then
					tablePlayer.Team = teams:WaitForChild("Spetsnaz");
				elseif #teams:WaitForChild("MARSOC"):GetPlayers() <= #teams:WaitForChild("Spetsnaz"):GetPlayers() then
					tablePlayer.Team = teams:WaitForChild("MARSOC");
				end
			end
				
			if tablePlayer.Team == teams:WaitForChild("Spetsnaz") then
				table.insert(spetsnazPlayers, tablePlayer);
			elseif tablePlayer.Team == teams:WaitForChild("MARSOC") then
				table.insert(marsocPlayers, tablePlayer);
			end
			repInitializeRemote:FireClient(tablePlayer);
		end
		activePlayers = readiedPlayerGroup;
		readiedPlayerGroup = {};
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
		trainModel:SetPrimaryPartCFrame(defaultTrainPosition);
	end
end

local trainRepDebounce = false;

local function departTrain()
	if trainRepDebounce == false then
		trainRepDebounce = true;
		repTrainDepartRemote:FireAllClients();
		for _, p in pairs(game:GetService("Players"):GetPlayers()) do
			if p.Character == nil then
				break;
			end
			local currentRoot = p.Character:FindFirstChild("HumanoidRootPart");
			if currentRoot == nil then
				break;
			end
			if currentRoot.Position.Z < pos1.Position.z and currentRoot.Position.x < pos1.Position.x then
				local rootTrainWeld = Instance.new("WeldConstraint", currentRoot);
				rootTrainWeld.Part0 = trainMain;
				rootTrainWeld.Part1 = currentRoot;
				if p.Team.Name == "MARSOC" then
					wait(1)
					updateMatch("Extracted")
					break;
				end
			end
		end
		wait(10)
		trainRepDebounce = false;
	end
end

--// Receipt Handling \\--

local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory");
local productFunctions = {}

productFunctions[1058905640] = function(receipt, customer)
	updateSavedData(customer, "UnspentSkillPoints", 2);
	return true;
end

local function processReceipt(receiptInfo)
 
	-- Determine if the product was already granted by checking the data store  
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	-- If purchase was recorded, the product was already granted
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end
 
	-- Find the player who made the purchase in the server
	local thisPlayer = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId)
	if not thisPlayer then
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Look up handler function from 'productFunctions' table above
	local handler = productFunctions[receiptInfo.ProductId]
 
	-- Call the handler function and catch any errors
	local success, result = pcall(handler, receiptInfo, thisPlayer)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", thisPlayer)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
 
	-- Record transaction in data store so it isn't granted again
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end
 
	-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
	return Enum.ProductPurchaseDecision.PurchaseGranted;
end

repDamageRemote.OnServerEvent:Connect(repDamage);
repCharacterRemote.OnServerEvent:Connect(repCharacters);
repShotRemote.OnServerEvent:Connect(repShot);
repEquipRemote.OnServerEvent:Connect(repEquip);
repReadiedPlayersRemote.OnServerEvent:Connect(repCheckStart);
repIncrementData.OnServerEvent:Connect(updateSavedData);
callTrainDepartRemote.OnServerEvent:Connect(departTrain);
repGetData.OnServerInvoke = getDataRemote;

MarketplaceService.ProcessReceipt = processReceipt