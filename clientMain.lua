local RunService = game:GetService("RunService");
local repStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local starterGui = game:GetService("StarterGui");
local players = game:GetService("Players");
local player = players.LocalPlayer;
local teamsService = game:GetService("Teams");

--Guns Setup

local g17Model = repStorage:WaitForChild("Glock17Model");
local UMP45Model = repStorage:WaitForChild("UMP .45Model");
local AK47Model = repStorage:WaitForChild("AK47Model");
local MP7A1Model = repStorage:WaitForChild("MP7A1Model")
local M60Model = repStorage:WaitForChild("M60Model");
local M4Model = repStorage:WaitForChild("M4Model");
local M870Model = repStorage:WaitForChild("M870Model");
local M249Model = repStorage:WaitForChild("M249Model");

local selectedWeapon;

local camera = game:GetService("Workspace").CurrentCamera;
local debris = game:GetService("Debris");
local mouse = player:GetMouse();
local StarterPlayer = game:GetService("StarterPlayer");
local teams = game:GetService("Teams");
local cameraShaker = require(script.CameraShaker);
local leaning = 0;

local playButton = workspace:WaitForChild("PlayButton"):WaitForChild("SurfaceGui"):WaitForChild("Escape");
local skillsButton = workspace:WaitForChild("SkillsButton"):WaitForChild("SurfaceGui"):WaitForChild("Skills");
local backButton = workspace:WaitForChild("BackButton"):WaitForChild("SurfaceGui"):WaitForChild("Back");

--// GUI Referrals \\--

local mainGUI = repStorage:WaitForChild("MainGui");

local function initializeGUI()
	
	local mainGUIClone = mainGUI:Clone();
	mainGUIClone.Parent = player.PlayerGui;
	
	mainFrame = mainGUIClone:WaitForChild("MainFrame");
	minutes = mainFrame:WaitForChild("Minutes");
	seconds = mainFrame:WaitForChild("Seconds");
	crosshair = mainFrame:WaitForChild("Crosshair");
	announcement = mainFrame:WaitForChild("Announcement");
	transition = mainGUIClone:WaitForChild("Transition");
	killMarker = mainFrame:WaitForChild("killMarker");
	killFeed = mainFrame:WaitForChild("KillFeed");
	
	equipment = mainGUIClone:WaitForChild("Equipment");
	weapons = equipment:WaitForChild("Weapons")
	skillTreeButton = equipment:WaitForChild("SkillTree");
	
	skillTreeFrame = mainGUIClone:WaitForChild("SkillTreeFrame");
	skillTreeBackButton = skillTreeFrame:WaitForChild("Return");
	points = skillTreeFrame:WaitForChild("UnspentPoints");
	level = skillTreeFrame:WaitForChild("Level");
	xpBar = skillTreeFrame:WaitForChild("ExperienceBar");
	bar = skillTreeFrame:WaitForChild("Bar");
	buySPButton = skillTreeFrame:WaitForChild("SPPurchase");
	
	skillTipFrame = mainGUIClone:WaitForChild("SkillTip");
	
	equipment.Visible = false;
	
	--[[coroutine.wrap(function()
    	local timeout = 1
    	local t = tick()
   	 	while not pcall(game.StarterGui.SetCore, game.StarterGui, "TopbarEnabled", false) and tick()-t<timeout do
    	    wait()
    	end
	end)()
	]]
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false);
end

local MarketplaceService = game:GetService("MarketplaceService")
 
local buySPID = 1058905640;
local SpecialMarsoc1ID = 11185504;

local buySP = MarketplaceService:GetProductInfo(buySPID, Enum.InfoType.Product)

local function promptSPPurchase()
	MarketplaceService:PromptProductPurchase(player, buySPID);
end

local function promptGPPurchase()
	MarketplaceService:PromptGamePassPurchase(player, SpecialMarsoc1ID);
end

--\\ GUI Referrals //--

--// Audio \\--

local audio = repStorage:WaitForChild("Audio");

local hitFlesh = audio:WaitForChild("hitFlesh2");
local equipSound1 = audio:WaitForChild("equipSound1");
local equipSound2 = audio:WaitForChild("equipSound2");
local killSound = audio:WaitForChild("hitFlesh1");

local glock17ReloadSound = audio:WaitForChild("glockReload");
local MP5SDReloadSound = audio:WaitForChild("MP5SDReload");
local AK47ReloadSound = audio:WaitForChild("AK47Reload");
local M60ReloadSound = audio:WaitForChild("M60Reload");
local M4ReloadSound = audio:WaitForChild("M4Reload");
local M249ReloadSound = audio:WaitForChild("M249Reload");
--local MP7A1ReloadSound = audio:WaitForChild("MP7A1Reload");

local rSounds = repStorage:WaitForChild("ReloadSounds");
local magIn = rSounds:WaitForChild("MagIn");
local magOut = rSounds:WaitForChild("MagOut");

local mouseEnter = audio:WaitForChild("mouseEnter");
local mouseClick = audio:WaitForChild("mouseClick");
local endOfRound = audio:WaitForChild("endOfRound");
local weaponSelect = audio:WaitForChild("weaponSelect");
local buySkill = audio:WaitForChild("buySkill");
local insufficientFunds = audio:WaitForChild("InsufficientFunds");
--local equipSound3 = repStorage:WaitForChild("equipSound3")
local ambience = audio:WaitForChild("Ambience");
local wooshSound = audio:WaitForChild("Transition");
local menuMusic = audio:WaitForChild("MenuMusic");
local loaded = audio:WaitForChild("Loaded");
menuMusic:Play();

--\\ Audio //--

-- // Remotes and Functions \\--

local repDamageRemote = repStorage:WaitForChild("ReplicateDamage");
local callTrainDepartRemote = repStorage:WaitForChild("CallTrainDepart");
local repCharactersRemote = repStorage:WaitForChild("ReplicateCharacters");
local repShotRemote = repStorage:WaitForChild("ReplicateShooting");
local repEquipRemote = repStorage:WaitForChild("ReplicateEquip");
local repReadiedPlayersRemote = repStorage:WaitForChild("ReplicateReadied");
local repInitializeRemote = repStorage:WaitForChild("ReplicateInitialize");
local repEndMatchRemote = repStorage:WaitForChild("ReplicateEndMatch");
local getDataRemote = repStorage:WaitForChild("GetData");
local incrementDataEvent = repStorage:WaitForChild("IncrementData");
local updateKillFeedRemote = repStorage:WaitForChild("UpdateKillFeed");

-- \\ Remotes and Functions //--

local hideParticles = {
	NumberSequenceKeypoint.new( 0, 0);    
	NumberSequenceKeypoint.new( 1, 0);   
}

local currentGun;
local thisChar;

--Initialize Camshake
		
local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	camera.CFrame = camera.CFrame * shakeCFrame;
end)
		
camShake:Start()

local reloading = false;
local equipping = false;

--// Skill Bools \\--
local hasSteadyAim = false;
local hasBetterPlates = false;
local hasQuickFeet = false;
local hasDeepPockets = false;
local hasEnforcer = false;
local enforcerLevel = 0;
local hasSleightOfHand = false;
local hasJuggernaut = false;
local juggernautActive = false;
local hasGuerillaTactics = false;
local guerillaTacticsActive = false;
local hasDrasticMeasures = false;
local drasticMeasuresActive = false;

--// Movement Vars \\--

local MinSpeed = 6;
local MaxSpeed = 13;

local function equip(weapon)
	
	if currentGun ~= weapon then
		if reloading == true then
			currentGun.reloadAnim:Stop();
			crosshair.Visible = true;
			reloading = false;
		end
		currentGun.shootAnim:Stop();
		equipping = true;
		mouseDown = false;
		local oldGun = currentGun;
		oldGun.clone.Parent = game.Lighting;
		currentGun = weapon;
		if hasSleightOfHand == true then
			currentGun.quickPullAnim:Play(0, 1, 1.2);
		else
			currentGun.quickPullAnim:Play(0, 1, 1);
		end
		
		wait()
		currentGun.clone.Parent = workspace;
		
		repEquipRemote:FireServer(thisChar, oldGun.ThirdPersonClone, currentGun.ThirdPersonClone);
		
		local strippedMuzzle = player.Character:WaitForChild(currentGun.ThirdPersonClone):WaitForChild("FirePart"); --here
			
		strippedMuzzle:WaitForChild("FlashFX3[Burst]").Size = NumberSequence.new(hideParticles);
		strippedMuzzle:WaitForChild("FlashFX3[Front]").Size = NumberSequence.new(hideParticles);
		strippedMuzzle:WaitForChild("FlashFX[Flash]").Size = NumberSequence.new(hideParticles);
		
		local random = math.random(1, 2)
		
		if random == 1 then
			equipSound1:Play()
		elseif random == 2 then
			equipSound2:Play()
		end
		
		currentGun.quickPullAnim.Stopped:Wait()
		equipping = false;
		currentGun.breatheAnim:Play(.2, .5, .5);
	end
end

--Setting up Character

local ownsSpecialMarsoc1 = false;

local debounce = 0;
local inQueue = false;

--promptGPPurchase();

--// Recoil Vars \\--

local hRecoil = 0;
local vRecoil = 0;
local recoilX = 0;
local recoilY = 0;
local stanceHeight = 0;
local recoilAmount = 0;
local deathDebounce = false;
local hitFleshDebounce = false;
local tickCheck = tick();
local killMarkerTick = 0;

local function initializeGame()
	if debounce == 0 then
		
		menuMusic:Stop();
		loaded:Play();
		
		transition.Visible = true;
		transition.BackgroundTransparency = 0;
		
		debounce = 1;
		inQueue = false;
		transition:WaitForChild("Waiting").Text = "Loading Match... (2/2)";
		
		repCharactersRemote:FireServer(repStorage:WaitForChild(player.Team.Name..math.random(1,2)), hasBetterPlates, hasJuggernaut);
		
		player.CharacterAdded:Wait();
		
		thisChar = player.Character;
		
		wait(2)
		
		local thisHum = thisChar:WaitForChild("Humanoid"); --problem problem
		
		ambience:Play();
		
		print(thisHum.Health)
		
		mainFrame.Visible = true;
		mainFrame.Transparency = 1;
		
		--Sounds Setup
		
		local FXFolder = repStorage:WaitForChild("FX");
		local glock17FireSound = FXFolder:WaitForChild("GlockFire");
		--local MP5SDFireSound = FXFolder:WaitForChild("MP5SDFire");
		local casingHit = FXFolder:WaitForChild("casingHit");
		local noBullet = FXFolder:WaitForChild("ranDry");
		
		--Object/Gun Setups
		
		local currentMag = 18;
		
		minutes.Text = "1";
		seconds.Text = "30";
		
		-- // Setup Glock \\--
				
		local glock = {
			clone = g17Model:Clone();
			head = nil;
			fireRate = 600; --600
			damage = 30; --30
			magSize = 18;
			recoil = 3; --3
			fireType = "Semi-Automatic";
			fireSound = glock17FireSound;
			reloadSound = glock17ReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "Glock17Stripped";
			reloadAnim = nil;
			currentMag = 18;
		}
		
		glock.head = glock.clone:WaitForChild("Head");
		glock.firePart = glock.clone:WaitForChild("FirePart");
		glock.clone.Parent = workspace;
		
		local animsFolder = glock.clone:WaitForChild("Anims");
		glock.shootAnim = glock.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		glock.shootAnim.Looped = false;
		glock.moveAnim = glock.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		glock.breatheAnim = glock.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		glock.reloadAnim = glock.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		glock.reloadAnim.Looped = false;
		
		glock.quickPullAnim = glock.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		glock.quickPullAnim.Looped = false;
		
		--\\ Setup Glock //--
		
		--// Setup AK47 \\--
		
		local AK47 = {
			clone = AK47Model:Clone();
			head = nil;
			fireRate = 600;--600
			damage = 40;
			magSize = 30;
			recoil = 3.5;
			fireType = "Automatic";
			reloadSound = AK47ReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			reloadAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "AK47Stripped";
			currentMag = 30;
		}
		
		AK47.head = AK47.clone:WaitForChild("Head");
		AK47.firePart = AK47.clone:WaitForChild("FirePart");
		AK47.clone.Parent = workspace;
		
		local animsFolder = AK47.clone:WaitForChild("Anims");
		AK47.shootAnim = AK47.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		AK47.shootAnim.Looped = false;
		AK47.moveAnim = AK47.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		AK47.breatheAnim = AK47.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		AK47.reloadAnim = AK47.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		AK47.reloadAnim.Looped = false;
		
		AK47.quickPullAnim = AK47.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		AK47.quickPullAnim.Looped = false;
		
		--\\ Setup AK47 //--

		--// Setup UMP .45 \\--
		
		local UMP45 = {
			clone = UMP45Model:Clone();
			head = nil;
			fireRate = 700;
			damage = 25;
			magSize = 30;
			recoil = 2.5;
			fireType = "Automatic";
			reloadSound = MP5SDReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			reloadAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "UMP .45Stripped";
			currentMag = 30;
		}
		
		UMP45.head = UMP45.clone:WaitForChild("Head");
		UMP45.firePart = UMP45.clone:WaitForChild("FirePart");
		UMP45.clone.Parent = workspace;
		
		local animsFolder = UMP45.clone:WaitForChild("Anims");
		UMP45.shootAnim = UMP45.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		UMP45.shootAnim.Looped = false;
		UMP45.moveAnim = UMP45.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		UMP45.breatheAnim = UMP45.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		UMP45.reloadAnim = UMP45.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		UMP45.reloadAnim.Looped = false;
		
		UMP45.quickPullAnim = UMP45.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		UMP45.quickPullAnim.Looped = false;
		
		--\\ Setup UMP .45 //--
		
		--// Setup MP7A1 \\--
		
		local MP7A1 = {
			clone = MP7A1Model:Clone();
			head = nil;
			fireRate = 950;
			damage = 25;
			magSize = 20;
			recoil = 2.8;
			fireType = "Automatic";
			reloadSound = MP5SDReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			reloadAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "MP7A1Stripped";
			currentMag = 21;
		}
		
		MP7A1.head = MP7A1.clone:WaitForChild("Head");
		MP7A1.firePart = MP7A1.clone:WaitForChild("FirePart");
		MP7A1.clone.Parent = workspace;
		
		local animsFolder = MP7A1.clone:WaitForChild("Anims");
		MP7A1.shootAnim = MP7A1.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		MP7A1.shootAnim.Looped = false;
		MP7A1.moveAnim = MP7A1.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		MP7A1.breatheAnim = MP7A1.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		MP7A1.reloadAnim = MP7A1.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		MP7A1.reloadAnim.Looped = false;
		
		MP7A1.quickPullAnim = MP7A1.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		MP7A1.quickPullAnim.Looped = false;
		
		--\\ Setup MP7A1 //--
		
		--// Setup M60 \\--
		
		local M60 = {
			clone = M60Model:Clone();
			head = nil;
			fireRate = 700;
			damage = 35;
			magSize = 80;
			recoil = 2;
			fireType = "Automatic";
			reloadSound = M60ReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			reloadAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "M60Stripped";
			currentMag = 81;
		}
		
		M60.head = M60.clone:WaitForChild("Head");
		M60.firePart = M60.clone:WaitForChild("FirePart");
		M60.clone.Parent = workspace;
		
		local animsFolder = M60.clone:WaitForChild("Anims");
		M60.shootAnim = M60.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		M60.shootAnim.Looped = false;
		M60.moveAnim = M60.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		M60.breatheAnim = M60.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		M60.reloadAnim = M60.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		M60.reloadAnim.Looped = false;
		
		M60.quickPullAnim = M60.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		M60.quickPullAnim.Looped = false;
		
		--\\ Setup M60//--
		
		--// Setup M4 \\--
		
		local M4 = {
			clone = M4Model:Clone();
			head = nil;
			fireRate = 750;
			damage = 46;
			magSize = 30;
			recoil = 2.5;
			fireType = "Automatic";
			reloadSound = M4ReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			reloadAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "M4Stripped";
			currentMag = 31;
		}
		
		M4.head = M4.clone:WaitForChild("Head");
		M4.firePart = M4.clone:WaitForChild("FirePart");
		M4.clone.Parent = workspace;
		
		local animsFolder = M4.clone:WaitForChild("Anims");
		M4.shootAnim = M4.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		M4.shootAnim.Looped = false;
		M4.moveAnim = M4.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		M4.breatheAnim = M4.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		M4.reloadAnim = M4.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		M4.reloadAnim.Looped = false;
		
		M4.quickPullAnim = M4.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		M4.quickPullAnim.Looped = false;
		
		--\\ Setup M4 //--
		
		--// Setup M870 \\--
		
		local M870 = {
			clone = M870Model:Clone();
			head = nil;
			fireRate = 100;
			damage = 20;
			magSize = 8;
			recoil = 9;
			fireType = "Spray";
			reloadSound = M4ReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			reloadAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "M870Stripped";
			currentMag = 8;
		}
		
		M870.head = M870.clone:WaitForChild("Head");
		M870.firePart = M870.clone:WaitForChild("FirePart");
		M870.clone.Parent = workspace;
		
		local animsFolder = M870.clone:WaitForChild("Anims");
		M870.shootAnim = M870.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		M870.shootAnim.Looped = false;
		M870.moveAnim = M870.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		M870.breatheAnim = M870.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		M870.reloadAnim = M870.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		M870.reloadAnim.Looped = false;
		
		M870.quickPullAnim = M870.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		M870.quickPullAnim.Looped = false;
		
		--\\ Setup M870 //--
		
		--// Setup M249 \\--
		
		local M249 = {
			clone = M249Model:Clone();
			head = nil;
			fireRate = 850;
			damage = 40;
			magSize = 200;
			recoil = 3;
			fireType = "Automatic";
			reloadSound = M249ReloadSound;
			firePart = nil;
			shootAnim = nil;
			moveAnim = nil;
			breatheAnim = nil;
			reloadAnim = nil;
			quickPullAnim = nil;
			ThirdPersonClone = "M249Stripped";
			currentMag = 200;
		}
		
		M249.head = M249.clone:WaitForChild("Head");
		M249.firePart = M249.clone:WaitForChild("FirePart");
		M249.clone.Parent = workspace;
		
		local animsFolder = M249.clone:WaitForChild("Anims");
		M249.shootAnim = M249.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Shoot"));
		M249.shootAnim.Looped = false;
		M249.moveAnim = M249.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Move"));
		M249.breatheAnim = M249.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Breathe"));
		M249.reloadAnim = M249.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("Reload"));
		M249.reloadAnim.Looped = false;
		
		M249.quickPullAnim = M249.clone:WaitForChild("AnimCTRL"):LoadAnimation(animsFolder:WaitForChild("QuickPull"));
		M249.quickPullAnim.Looped = false;
		
		--\\ Setup M249 //--
		
		if selectedWeapon == "AK47" then
			primaryWeapon = AK47;
		elseif selectedWeapon == "MP7A1" then
			primaryWeapon = MP7A1;
		elseif selectedWeapon == "M60" then
			primaryWeapon = M60;
		elseif selectedWeapon == "M4" then
			primaryWeapon = M4;
		elseif selectedWeapon == "M870" then
			primaryWeapon = M870;
		elseif selectedWeapon == "M249" then
			primaryWeapon = M249;
		else
			primaryWeapon = UMP45;
		end
		secondaryWeapon = glock;
		
		local crouchAnim = thisChar:WaitForChild("Humanoid"):LoadAnimation(thisChar:WaitForChild("Animations"):WaitForChild("crouch"));
		local leanLeftAnim = thisChar:WaitForChild("Humanoid"):LoadAnimation(thisChar:WaitForChild("Animations"):WaitForChild("leanLeft"));
		local leanRightAnim = thisChar:WaitForChild("Humanoid"):LoadAnimation(thisChar:WaitForChild("Animations"):WaitForChild("leanRight"));
		
		--Animations Setup
		
		if hasQuickFeet == true then
			MaxSpeed = 13.8;
		end
		
		thisHum.WalkSpeed = MinSpeed
		
		local MoveDirDB = false
	
		local function Accelerate()
			if thisHum.MoveDirection ~= Vector3.new(0, 0, 0) and MoveDirDB == false and thisHum.WalkSpeed < MaxSpeed then
				MoveDirDB = true
				while thisHum.MoveDirection ~= Vector3.new(0, 0, 0) and thisHum.WalkSpeed < MaxSpeed do
					thisHum.WalkSpeed = thisHum.WalkSpeed + 1;
					RunService.Heartbeat:Wait();				
				end
				MoveDirDB = false
			elseif thisHum.WalkSpeed > MaxSpeed then
				thisHum.WalkSpeed = MaxSpeed;
			elseif thisHum.MoveDirection == Vector3.new(0, 0, 0) then
				thisHum.WalkSpeed = MinSpeed;			
			end
		end
		
		
		local runningDebounce = false;
		local originalHeadCF;
		
		local function update()
			
			Accelerate();
			
			if leaning == 1 then
				thisHum.CameraOffset = thisHum.CameraOffset:lerp(Vector3.new(-1.2, -0.1 + stanceHeight, 0), .25); -- lean left
				camera.CFrame = camera.CFrame:lerp(currentGun.head.CFrame * CFrame.Angles(0, 0, math.rad(20)), .25);
			elseif leaning == 0 then
				thisHum.CameraOffset = thisHum.CameraOffset:lerp(Vector3.new(0, 0 + stanceHeight, 0), .25); -- no lean
			elseif leaning == 2 then
				thisHum.CameraOffset = thisHum.CameraOffset:lerp(Vector3.new(1.2, -0.1 + stanceHeight, 0), .25); -- lean right
				camera.CFrame = camera.CFrame:lerp(currentGun.head.CFrame * CFrame.Angles(0, 0, math.rad(-20)), .25);
			end
			
			if thisChar and thisChar:FindFirstChild("HumanoidRootPart") and thisChar.HumanoidRootPart.Velocity.Magnitude > 0.5 then
				--currentGun.moveAnim:AdjustWeight(thisChar.HumanoidRootPart.Velocity.Magnitude/13);
				if currentGun.moveAnim.IsPlaying == false then
					currentGun.moveAnim:Play(.1, .7, 1);
				end
			else
				currentGun.moveAnim:Stop(.1);
			end
			
			if hitFleshDebounce == true then
			
				RunService.Heartbeat:Wait();
				hitFleshDebounce = false;
				
			end
			
			if recoilX ~= 0 then
        
        		recoilX = recoilX + 2
       			camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(vRecoil * (recoilY/100)), math.rad(hRecoil * (recoilY/100)), 0);
        		recoilY = -recoilX^2 + 100
        		camera.FieldOfView = -1.75 * recoilAmount * math.sin(1/5 * recoilX) + 75

				if recoilX == 0 then
					
					local muzzleFX = currentGun.firePart:GetChildren();
					for i = 1, #muzzleFX do
						muzzleFX[i].Enabled = false;
					end
					
				end
				
			end
			
			if killMarkerTick > 0 then
				killMarkerTick = killMarkerTick - 1;
				if killMarkerTick < 1 then
					killMarker.Visible = false;
				end
			end
			
			currentGun.head.CFrame = camera.CFrame;
			
			if tick() - tickCheck >= 1 then
				tickCheck = tick();
				if tonumber(seconds.Text) > 0 then
					seconds.Text = seconds.Text - 1;
					if tonumber(seconds.Text) < 10 then
						seconds.Text = "0"..seconds.Text;
					end
				elseif tonumber(minutes.Text) > 0 then
					minutes.Text = minutes.Text - 1;
					seconds.Text = "59";
				elseif tonumber(minutes.Text) == 0 then
					print("timer over, train leaving");
					callTrainDepartRemote:FireServer();
				end
			end
			
			if thisHum.Health < thisHum.MaxHealth/2 then
				if hasJuggernaut then
					thisHum.Health = thisHum.Health + 0.03;
				end
				if hasDrasticMeasures then
					MaxSpeed = 16.56;
					drasticMeasuresActive = true;
				end
			end
		end
		
		local function ejectShell()
			local sClone = currentGun.clone:WaitForChild("Shell"):Clone();
			sClone.Parent = workspace;
			sClone:WaitForChild("ShellWeld"):Destroy();
			--[[local shellBodyVelocity = Instance.new("BodyVelocity");
			shellBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000);
			shellBodyVelocity.P = 1250;
			shellBodyVelocity.Velocity = sClone.CFrame.LookVector
			]]
			--sClone.CanCollide = true;
			local cHSoundClone = casingHit:Clone();
			cHSoundClone.Parent = thisChar:WaitForChild(currentGun.ThirdPersonClone);
			debris:AddItem(sClone, 4);
			debris:AddItem(cHSoundClone, 0.8);
		end
		
		local function recoil(amount)
			camShake:ShakeOnce(amount/5, 3, 0.1, amount/8)
			hRecoil = math.random(-amount, amount)/10;
    		vRecoil = math.random(amount, amount + amount/2)/7;
    		recoilX, recoilY = -10, 0;
    		recoilAmount = amount;
		end
		
		local function raycast(gunModel, damage, spread)
			local innaccuracyX = 0;
			local innaccuracyY = 0;
			
			if spread then
				innaccuracyX = math.random(-1.8, 1.8);
				innaccuracyY = math.random(-1.8, 1.8);
			end
			
			local ray = Ray.new(camera.CFrame.p, ((camera.CFrame * CFrame.new(innaccuracyX, innaccuracyY, -50).p) - camera.CFrame.p).unit * 300);
			local hitPart, hitPos, hitNorm = workspace:FindPartOnRay(ray, player.Character, false, true);
			
			--local distance = (glock.firePart.CFrame.p - hitPos).magnitude;
					
			if hitPart then
				local shotDamage = currentGun.damage;
				
				if hitPart.Name == "Head" or hitPart.Name == "HeadGear" then
					shotDamage = shotDamage * 3;
				elseif hitPart.Name == "UpperTorso" or hitPart.Name == "TorsoPart" then
					shotDamage = shotDamage * 1.2;
				else
					shotDamage = shotDamage * 0.8;
				end
				
				shotDamage = shotDamage + ((shotDamage * .25) * enforcerLevel)
				if guerillaTacticsActive then
					shotDamage = shotDamage * 1.25;
				end
				repDamageRemote:FireServer(hitPart, shotDamage, hitPos, hitNorm, (camera.CFrame * CFrame.new(0, 0, -100).p), currentGun.firePart.Position); --player, part, damage, position, normal, startPos
				if hitPart.Parent and (string.find(hitPart.Parent.Name, "Spetsnaz") or string.find(hitPart.Parent.Name, "MARSOC")) and hitFleshDebounce == false then
					hitFleshDebounce = true;
					
					local hitFleshClone = hitFlesh:Clone();
					hitFleshClone.PlaybackSpeed = math.random(90, 110)/100;
					hitFleshClone.Parent = thisChar;
					hitFleshClone:Destroy();
					
					if hitPart.Name == "HeadGear" or hitPart.Name == "Head" then
						local deathEffectClone = audio:WaitForChild("killReward"):Clone();
						deathEffectClone.PlaybackSpeed = math.random(90, 110)/100;
						deathEffectClone.Parent = thisChar;
						deathEffectClone:Destroy();
					end
					if string.find(hitPart.Parent.Name, "Ragdoll") == nil then
						if hitPart.Parent:WaitForChild("Humanoid").Health - shotDamage <= 0 then
							killMarker.Visible = true;
							killMarkerTick = 30;
							local killSoundClone = killSound:Clone();
							killSoundClone.Parent = thisChar;
							killSoundClone:Destroy();
							if hasEnforcer == true then
								enforcerLevel = enforcerLevel + 1;
							end
						end
					else
						local ragdollForce = Instance.new("VectorForce", hitPart);
						ragdollForce.Force = Vector3.new(0, 0, -1500);
						ragdollForce.Attachment1 = thisChar:WaitForChild("Head"):WaitForChild("RagdollFAttachment");
						ragdollForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment1;
						local forceAttachment = Instance.new("Attachment", hitPart);
						ragdollForce.Attachment0 = forceAttachment;
						debris:AddItem(ragdollForce, .05);
					end
				end
			end
			
		end
		
		local lastTick = tick();
		
		local function fireWeapon(spray)
			local fireCooldown = 60/currentGun.fireRate;
			if drasticMeasuresActive then
				fireCooldown = (60/currentGun.fireRate) * .8;
			end
			if (tick() - lastTick) > fireCooldown and currentGun.currentMag > 0 and reloading == false and equipping == false then
				
				thisHum.WalkSpeed = 7;
				
				currentGun.currentMag = currentGun.currentMag - 1;
				lastTick = tick();
				repShotRemote:FireServer(thisChar:WaitForChild(currentGun.ThirdPersonClone));
				local muzzleFX = currentGun.firePart:GetChildren();
				for i = 1, #muzzleFX do
					muzzleFX[i].Enabled = true;
				end
				if currentGun ~= M870 then
					currentGun.shootAnim:Play(.1, .95, 2.25);
				else
					currentGun.shootAnim:Play(.1, .925, 1);
				end
				if spray then
					for i = 0, 8, 1 do
						raycast(currentGun.clone, currentGun.damage, true);
					end
				end
				raycast(currentGun.clone, currentGun.damage);
				
				if currentGun ~= M870 then
					ejectShell();
				end
				
				if hasSteadyAim and stanceHeight == -1.25 then
					recoil(currentGun.recoil * .65);
				else
					recoil(currentGun.recoil);		
				end
				if currentGun == M870 then
					currentGun.shootAnim:GetMarkerReachedSignal("BoltBack"):Connect(function()
     					currentGun.clone:WaitForChild("Bolt"):WaitForChild("BoltBack"):Play();
					end)
					currentGun.shootAnim:GetMarkerReachedSignal("BoltForward"):Connect(function()
     					currentGun.clone:WaitForChild("Bolt"):WaitForChild("BoltForward"):Play();
					end)
				end
			else
				if currentGun.currentMag < 1 then
					local eSoundClone = noBullet:Clone();
					eSoundClone.Parent = glock17FireSound.Parent;
					eSoundClone.PlaybackSpeed = math.random(90, 100)/100;
					eSoundClone:Play();
					wait(3)
				end
			end
			wait();
		end
		
		local function shoot() 
			if currentGun.fireType == "Semi-Automatic" then
				
				fireWeapon();
				
			elseif currentGun.fireType == "Automatic" then
				
				repeat
					
					fireWeapon();
					
				until mouseDown == false;
				
			elseif currentGun.fireType == "Spray" then 
				
				repeat
					
					fireWeapon(true);
					
				until mouseDown == false;
				
			end
		end
		
		local function keyDown(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				mouseDown = true
				shoot();
			elseif inputObject.KeyCode == Enum.KeyCode.R and reloading == false then
				local reloadingGun = currentGun;
				reloading = true;
				crosshair.Visible = false;
				
				if hasSleightOfHand == true then
					currentGun.reloadAnim:Play(.05, .9, 1.44);
					currentGun.reloadSound.PlaybackSpeed = currentGun.reloadSound.PlaybackSpeed * 1.2;
				else
					currentGun.reloadAnim:Play(.05, .9, 1.2);
					currentGun.reloadSound:Play();
				end
				
				currentGun.reloadAnim.Stopped:Wait();
				crosshair.Visible = true;
				wait();
				if currentGun == reloadingGun then
					if hasDeepPockets == true then
						currentGun.currentMag = currentGun.magSize * 1.2;
					else
						currentGun.currentMag = currentGun.magSize;
					end
					reloading = false;
				end
			elseif inputObject.KeyCode == Enum.KeyCode.Q then --lean left
				if leaning == 0 then
					leanLeftAnim:Play();
					leaning = 1;
					return;
				elseif leaning == 1 or leaning == 2 then
					leanLeftAnim:Stop();
					leanRightAnim:Stop();
					leaning = 0;
					return;
				end
			elseif inputObject.KeyCode == Enum.KeyCode.E then --lean right
				if leaning == 0 then
					leanRightAnim:Play();
					leaning = 2;
					return;
				elseif leaning == 2 or leaning == 1 then
					leanLeftAnim:Stop();
					leanRightAnim:Stop();
					leaning = 0;
					return;
				end
			elseif inputObject.KeyCode == Enum.KeyCode.Two then
				equip(secondaryWeapon);
			elseif inputObject.KeyCode == Enum.KeyCode.One then
				equip(primaryWeapon);
			elseif inputObject.KeyCode == Enum.KeyCode.C then
				stanceHeight = -1.25;
				if hasGuerillaTactics then
					MaxSpeed = MaxSpeed - 5;
				else
					MaxSpeed = MaxSpeed - 8;
				end
				crouchAnim:Play(.2);
				guerillaTacticsActive = true;
			end
		end
		
		
		thisHum.Jumping:Connect(function()
			local thisRoot = thisChar:FindFirstChild("HumanoidRootPart");
			repeat 
				RunService.Heartbeat:Wait() 
			until thisHum.FloorMaterial ~= Enum.Material.Air;
			thisHum.JumpHeight = 0;
		end)
			
		local function keyUp(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				mouseDown = false
			elseif inputObject.KeyCode == Enum.KeyCode.C then
				stanceHeight = 0;
				if hasGuerillaTactics then
					MaxSpeed = MaxSpeed + 5;
				else
					MaxSpeed = MaxSpeed + 8;
				end
				crouchAnim:Stop(.2);
				guerillaTacticsActive = false;
			elseif inputObject.KeyCode == Enum.KeyCode.Space then
				thisHum.JumpHeight = 2;
			end
		end
		
		local function healthChange(amount)
			if thisHum.Health <= 0 and deathDebounce == false then
				deathDebounce = true;
				--dieAnim:Play(1);
				print("You Died")
				connection:Disconnect();
				updateConnection:Disconnect();
				disconnection:Disconnect();
				crosshair.Visible = false;
				currentGun.clone:Destroy();
				repDamageRemote:FireServer("reset");
				wait(1)
				deathDebounce = false;
			else
				
			end
		end
		
		currentGun = secondaryWeapon;
		equip(primaryWeapon); -- place this here because update() references the currentGun
		
		updateConnection = RunService.RenderStepped:Connect(update);
		connection = UserInputService.InputBegan:Connect(keyDown);
		disconnection = UserInputService.InputEnded:Connect(keyUp);
		
		debounce = 0;
		wait()
		
		for i = 0, 100, 2 do
			transition.BackgroundTransparency = i/100;
			transition:WaitForChild("Waiting").TextTransparency = i/100;
			transition:WaitForChild("DYK").TextTransparency = i/100;
			wait()
		end
		
		wait(1);
		
		if player.Team.Name == "Spetsnaz" then
			announcement.Text = "You are Spetsnaz. Kill the Intruders."
			workspace:WaitForChild("RussianOpening"):Play();
		else
			announcement.Text = "You are Marsoc. Escape the Station."
			workspace:WaitForChild("USOpening"):Play();
		end
		
		announcement.Visible = true;
		mainFrame.Transparency = 0.78;
		announcement.TextTransparency = 0;
		
		wait(3);
		
		for i = 20, 0, -.2 do
			mainFrame.Transparency = 1 - i/90;
			announcement.TextTransparency = 1 - i/20;
			RunService.Heartbeat:Wait();
		end
		
		crosshair.Visible = true;
		
		announcement.Visible = false;
		transition.Visible = false;
		
		thisHum.HealthChanged:Connect(healthChange);
		
		--End Initialization
	end
end

-- // Begin Menu \\--

local skillsCam = workspace:WaitForChild("CameraPos2");
local mainCam = workspace:WaitForChild("CameraPos");

camera.CameraType = "Scriptable"
	
camera.CFrame = mainCam.CFrame;
	
camShake:ShakeSustain(camShake.Presets.HandheldCamera)

local function onHover()
	mouseEnter:Play();
	playButton.TextTransparency = 0;
end

local function onEndHover()
	playButton.TextTransparency = .4;
end

local function onHoverSkills()
	mouseEnter:Play();
	skillsButton.TextTransparency = 0;
end

local function onEndHoverSkills()
	skillsButton.TextTransparency = .4;
end

local function onHoverBack()
	mouseEnter:Play();
	backButton.TextTransparency = 0;
end

local function onEndHoverBack()
	backButton.TextTransparency = .4;
end

local enteringSkillsScreen = true;

local function onClickSkills()
	mouseClick:Play();
	equipment.Visible = true;
	for i = -0.5, 0, .01 do
		if enteringSkillsScreen == true then
			equipment.Position = UDim2.fromScale(-math.sin(2 * i)^2 - .01, 0);
			camera.CFrame = camera.CFrame:lerp(skillsCam.CFrame, i*2 + 1);
			RunService.Heartbeat:Wait();
		end
	end
end

local function onClickBack()
	mouseClick:Play();
	enteringSkillsScreen = false;
	for i = -1, 0, .02 do
		camera.CFrame = camera.CFrame:lerp(mainCam.CFrame, i + 1);
		equipment.Position = UDim2.fromScale(-i - 1.1, 0);
		RunService.Heartbeat:Wait();
	end
	enteringSkillsScreen = true;
	equipment.Visible = false;
end

local function onClickSkillTree()
	mouseClick:Play();
	skillTreeFrame.Visible = true;
	equipment.Visible = false;
	points.Text = getDataRemote:InvokeServer("UnspentSkillPoints");
	local thisXP = getDataRemote:InvokeServer("Experience");
	local thisLevel = getDataRemote:InvokeServer("Level");
	level.Text = thisLevel;
	xpBar.Text = (thisXP.."/"..math.floor((thisLevel^1.5 * 5) + 10));
	print(thisXP/(math.floor((thisLevel^1.5 * 5) + 10))/10)
	bar.Size = UDim2.new(thisXP/(math.floor((thisLevel^1.5 * 5) + 10))/10, 0, .035, 0);
end

local function onClickSkillTreeBack()
	mouseClick:Play();
	skillTreeFrame.Visible = false;
	equipment.Visible = true;
end

local function onHoverSkillTreeBack() -- This section doesn't adhere to D.R.Y. right now because I'm lazy
	mouseEnter:Play();
	skillTreeBackButton.TextTransparency = 0.5;
end

local function onHoverBuySP()
	mouseEnter:Play();
	buySPButton.TextTransparency = .4;
end

local function onEndHoveBuySP()
	buySPButton.TextTransparency = 0;
end

local function buySPClick()
	mouseClick:Play();
	promptSPPurchase();
end

local function onHoverEndSkillTreeBack()
	skillTreeBackButton.TextTransparency = 0;
end

local function onHoverSkillTree()
	mouseEnter:Play();
	skillTreeButton.TextTransparency = 0;
end

local function onEndHoverSkillTree()
	skillTreeButton.TextTransparency = .4;
end

local oldSelect;
local specifiedWeapon;

local function selectWeapon(weapon) --argument is a weapon frame containing the button, lock, name, tips, etc.
	if weapon:WaitForChild("Lock").Visible == false then
		if oldSelect ~= nil and oldSelect.Name == weapon.Name then
			return;
		end
		if oldSelect then
			oldSelect:WaitForChild("Button").BackgroundTransparency = 1;
			specifiedWeapon.Parent = repStorage;
		end
		
		specifiedWeapon = repStorage:WaitForChild(weapon.Name .. "Display");
		weaponSelect:Play();
		specifiedWeapon.Parent = workspace;
		specifiedWeapon:SetPrimaryPartCFrame(workspace:WaitForChild("WeaponDisplay").CFrame);
		oldSelect = weapon
		oldSelect:WaitForChild("Button").BackgroundTransparency = 0.7;
		
		selectedWeapon = weapon.Name;
	end
end

local function instantiateWeaponButtons()
	local weaponMenuChildren = weapons:GetChildren();
	
	for _, weapon in ipairs(weaponMenuChildren) do
		weapon:WaitForChild("Button").MouseButton1Click:Connect(function()
			selectWeapon(weapon)
		end)
	end
end

local function colorSkillButton(skill)
	--skill.BackgroundColor3 = Color3.new(247, 247, 247);
	skill.BackgroundTransparency = 0;
	skill.BorderColor3 = Color3.new(250, 250, 250)
	skill.BorderSizePixel = 4;
end

local mySkills = {};
local alreadyOwned = false;

local function updateStatsTree(ability)
	
	local skillMenuChildren = skillTreeFrame:GetChildren();
	
	for _, skill in ipairs(skillMenuChildren) do
		
		if skill:FindFirstChild("Name") then
		
			if ability == "startup" then
				
				if getDataRemote:InvokeServer(skill:WaitForChild("Name").Value) == 1 then
					
					for i = 1, #mySkills, 1 do
						if mySkills[i] == skill:WaitForChild("Name").Value then
							print("Already knew about " .. skill:WaitForChild("Name").Value);
							alreadyOwned = true;
						end
					end
					
					if alreadyOwned == false then			
						table.insert(mySkills, skill:WaitForChild("Name").Value);
							
						colorSkillButton(skill)
					end
					
					alreadyOwned = false;
					
					if string.find(skill.Name, 1) ~= nil then
						for _, skillJ in ipairs (skillMenuChildren) do
							if string.find(string.sub(skillJ.Name, 1, string.len(skillJ.Name) - 1), string.sub(skill.Name, 1, string.len(skill.Name) - 1)) ~= nil then
								if string.find(skillJ.Name, 2) ~= nil or string.find(skillJ.Name, 3) ~= nil then
									skillJ:WaitForChild("Lock").Visible = false;
								end
							end
						end
						
					elseif string.find(skill.Name, 2) ~= nil or string.find(skill.Name, 3) ~= nil then
					
						for _, skillJ in ipairs (skillMenuChildren) do
							if string.find(string.sub(skillJ.Name, 1, string.len(skillJ.Name) - 1), string.sub(skill.Name, 1, string.len(skill.Name) - 1)) ~= nil then
								if string.find(skillJ.Name, 4) ~= nil or string.find(skillJ.Name, 5) ~= nil then
									skillJ:WaitForChild("Lock").Visible = false;
								end
							end
						end
					end
				
				end
				
			else --update previously created array with new information
				
				for i = 1, #mySkills, 1 do
					if mySkills[i] == ability:WaitForChild("Name").Value then
						alreadyOwned = true;
					end
				end
				
				if alreadyOwned == false then
				
					table.insert(mySkills, ability:WaitForChild("Name").Value);
				
				end
				
				alreadyOwned = false;
				
				if string.find(ability.Name, 1) ~= nil then
					for _, skillJ in ipairs (skillMenuChildren) do
						if string.find(string.sub(skillJ.Name, 1, string.len(skillJ.Name) - 1), string.sub(ability.Name, 1, string.len(ability.Name) - 1)) ~= nil then
							if string.find(skillJ.Name, 2) ~= nil or string.find(skillJ.Name, 3) ~= nil then
								skillJ:WaitForChild("Lock").Visible = false;
							end
						end
					end
					
				elseif string.find(ability.Name, 2) ~= nil or string.find(ability.Name, 3) ~= nil then
					
					for _, skillJ in ipairs (skillMenuChildren) do
						if string.find(string.sub(skillJ.Name, 1, string.len(skillJ.Name) - 1), string.sub(ability.Name, 1, string.len(ability.Name) - 1)) ~= nil then
							if string.find(skillJ.Name, 4) ~= nil or string.find(skillJ.Name, 5) ~= nil then
								skillJ:WaitForChild("Lock").Visible = false;
							end
						end
					end
				end
				
			end
			
		end
	end
	
	print("your skills are: ")
	for i = 0, #mySkills, 1 do
		print(mySkills[i]);
		if mySkills[i] == "AK47" then
			
			weapons:WaitForChild("AK47"):WaitForChild("Lock").Visible = false;
			selectWeapon(weapons:WaitForChild("AK47"))
			
		elseif mySkills[i] == "Steady Aim" then
				
			hasSteadyAim = true;
			
		elseif mySkills[i] == "Quick Feet" then
				
			hasQuickFeet = true;
			
		elseif mySkills[i] == "Better Plates" then
					
			hasBetterPlates = true;
			
		elseif mySkills[i] == "Deep Pockets" then
					
			hasDeepPockets = true;
			print("Deep Pockets Equipped")
			
		elseif mySkills[i] == "Sleight of Hand" then
			
			hasSleightOfHand = true;
			print("Sleight of Hand equipped")
			
		elseif mySkills[i] == "Juggernaut" then
			
			hasJuggernaut = true;
			print("Juggernaut equipped")
			
		elseif mySkills[i] == "Guerilla Tactics" then
			
			hasGuerillaTactics = true;
			print("Guerilla Tactics equipped");
			
		elseif mySkills[i] == "Drastic Measures" then
			
			hasDrasticMeasures = true;
			print("Drastic Measures equipped")
			
		elseif mySkills[i] == "Enforcer" then
			
			hasEnforcer = true;
			print("Enforcer equipped")
			
		elseif mySkills[i] == "MP7" then
					
			weapons:WaitForChild("MP7A1"):WaitForChild("Lock").Visible = false;	
			selectWeapon(weapons:WaitForChild("MP7A1"))
			
		elseif mySkills[i] == "M60" then
					
			weapons:WaitForChild("M60"):WaitForChild("Lock").Visible = false;	
			selectWeapon(weapons:WaitForChild("M60"))
			
		elseif mySkills[i] == "M4" then
					
			weapons:WaitForChild("M4"):WaitForChild("Lock").Visible = false;	
			selectWeapon(weapons:WaitForChild("M4"))
			
		elseif mySkills[i] == "M870" then
			
			weapons:WaitForChild("M870"):WaitForChild("Lock").Visible = false;
			selectWeapon(weapons:WaitForChild("M870"))
			
		elseif mySkills[i] == "M249" then
			
			weapons:WaitForChild("M249"):WaitForChild("Lock").Visible = false;
			selectWeapon(weapons:WaitForChild("M249"))
					
		end
	end
	
end

local function selectSkill(skill)
	if getDataRemote:InvokeServer(skill:WaitForChild("Name").Value) == 1 then --get the wanted datastore value with the Name string value indexing a 2D array of all skill datastores
		
		print("Owned: " .. getDataRemote:InvokeServer(skill:WaitForChild("Name").Value))
			
	else
		
		if skill:FindFirstChild("Lock").Visible == false and tonumber(points.Text) >= skill:WaitForChild("Cost").Value then
			buySkill:Play();
			
			colorSkillButton(skill)
			print("purchased "..skill.Name.." for "..skill:WaitForChild("Cost").Value.." skill points")
			incrementDataEvent:FireServer("UnspentSkillPoints", skill:WaitForChild("Cost").Value * -1);
			print(getDataRemote:InvokeServer("UnspentSkillPoints"))
			incrementDataEvent:FireServer(skill:WaitForChild("Name").Value, 1);
			updateStatsTree(skill);
			points.Text = points.Text - skill:WaitForChild("Cost").Value;
		else
			insufficientFunds:Play();
			print(getDataRemote:InvokeServer(skill:WaitForChild("Name").Value))
		end
	end
	
	return;
end

local function hoverSkill(skill)
	mouseEnter:Play();
	skillTipFrame.Visible = true;
	skillTipFrame:WaitForChild("Name").Text = skill:WaitForChild("Name").Value;
	skillTipFrame:WaitForChild("Tip").Text = skill:WaitForChild("Info").Value;
	skillTipFrame:WaitForChild("Cost").Text = skill:WaitForChild("Cost").Value .. " Skill Points"
	skillTipFrame.Position = UDim2.new(0, mouse.X, 0, mouse.Y - 20);
end

local function hoverEndSkill(skill)
	skillTipFrame.Visible = false;
end

local function instantiateSkillButtons()
	local skillMenuChildren = skillTreeFrame:GetChildren();
	
	for _, skill in ipairs(skillMenuChildren) do
		if string.find(skill.Name, "Skill") ~= nil then
			skill.MouseButton1Click:Connect(function()
				selectSkill(skill);
			end)
			skill.MouseEnter:Connect(function()
				hoverSkill(skill);
			end)
			skill.MouseLeave:Connect(function()
				hoverEndSkill(skill);
			end)
		end
	end
end

local playDebounce = false;

local function onClickPlay()
	if playDebounce == false then
		playDebounce = true;
		mouseClick:Play();
		transition.Visible = true;
		skillTreeFrame.Visible = false;
		equipment.Visible = false;
		if workspace:WaitForChild("GameActive").Value == true then
			transition:WaitForChild("Waiting").Text = "Waiting For Next Match (spectating coming soon)";
		else
			transition:WaitForChild("Waiting").Text = "Waiting For Players (1/2)";
		end
		for i = 100, 0, -5 do
			transition:WaitForChild("Waiting").TextTransparency = i/100;
			transition.BackgroundTransparency = i/100;
			transition:WaitForChild("LoadingScreen").ImageTransparency = i/100 + .1;
			RunService.Heartbeat:Wait();
		end
		wait(1)
		UserInputService.MouseIconEnabled = false;
		inQueue = true;
		repReadiedPlayersRemote:FireServer();
		print(player.Name .. " joined the queue")
		camera.CameraType = "Custom";
		camShake:StopSustained(1);
		while inQueue == true do
			
			local randomTip = math.random(1, 11);
			if randomTip == 1 then
				transition:WaitForChild("DYK").Text = "Aim for the head - headshots deal significantly more damage";
			elseif randomTip == 2 then
				transition:WaitForChild("DYK").Text = "Try to avoid shooting for the legs - leg shots deal less damage than chest shots";
			elseif randomTip == 3 then
				transition:WaitForChild("DYK").Text = "You can lean left or right using Q or E";
			elseif randomTip == 4 then
				transition:WaitForChild("DYK").Text = "Upper chest shots deal slight increased damage";
			elseif randomTip == 5 then
				transition:WaitForChild("DYK").Text = "You can unlock more weapons in the Skill Tree";
			elseif randomTip == 6 then
				transition:WaitForChild("DYK").Text = "You can unlock special perks in the Skill Tree";
			elseif randomTip == 7 then
				transition:WaitForChild("DYK").Text = "Move with your team - even the most experienced will eventually run out of bullets";
			elseif randomTip == 8 then
				transition:WaitForChild("DYK").Text = "Use your ears: your enemies are louder than they think";
			elseif randomTip == 9 then
				transition:WaitForChild("DYK").Text = "You can buy Skill Points in the menu";
			elseif randomTip == 10 then
				transition:WaitForChild("DYK").Text = "If you experience a bug, try rejoining";
			elseif randomTip == 11 then
				transition:WaitForChild("DYK").Text = "You can buy Character Skins on the game page";
			end
			
			for i = 100, 0, -2 do
				transition:WaitForChild("DYK").TextTransparency = i/100;
				RunService.Heartbeat:Wait();
			end
			
			wait(4)
			
			for i = 0, 100, 2 do
				transition:WaitForChild("DYK").TextTransparency = i/100;
				RunService.Heartbeat:Wait();
			end
		end
		wait(3)
		playDebounce = false;
	end
end

local function cleanupCharacter()
	
	if primaryWeapon and primaryWeapon.clone then
		primaryWeapon.clone:Destroy();
	end
	if secondaryWeapon and secondaryWeapon.clone then
		secondaryWeapon.clone:Destroy();
	end
	if player.Character then
		player.Character:Destroy();
	end
	if updateConnection ~= nil then
		updateConnection:Disconnect();
	end
	if connection ~= nil then
		connection:Disconnect();
	end
	if disconnection ~= nil then
		disconnection:Disconnect();
	end
end

local function cleanupRagdolls()
	local children = workspace:GetChildren();
	for i = 1, #children do
		if string.find(children[i].Name, "Ragdoll") then
			children[i]:Destroy();
		end
	end
end

local trainModel = workspace:WaitForChild("de_metro"):WaitForChild("Geometry"):WaitForChild("Metro Train");
local trainMain = trainModel:WaitForChild("TrainMain");
local defaultTrainPosition = trainMain.CFrame;

local killFeedArray = {};

local function endMatch(winningTeam, winningCondition)
	
	wait(1)
	
	enforcerLevel = 0;
	
	announcement.Visible = true;
	mainFrame.Visible = true;
	
	endOfRound:Play();
	
	if winningTeam == "Spetsnaz" then
		announcement.Text = "Secured by Spetsnaz"
		mainFrame:WaitForChild("SpetsScore").Text = workspace:WaitForChild("SpetsScore").Value;
	elseif winningTeam == "MARSOC" then
		announcement.Text = "Secured by MARSOC"
		mainFrame:WaitForChild("MarsocScore").Text = workspace:WaitForChild("MARSOCScore").Value;
	end
	
	wooshSound:Play();
	
	for i = 0, 20, .1 do
		mainFrame.Transparency = 1 - i/90;
		announcement.TextTransparency = 1 - i/20;
		RunService.Heartbeat:Wait();
	end
	
	for i = 1, #killFeedArray do
		killFeedArray[i]:Destroy();
	end
	
	killFeedArray = {};
	
	wait(5)
	
	cleanupRagdolls();
	
	mainFrame.Visible = false;
	announcement.Visible = false;
	cleanupCharacter();
	if tonumber(mainFrame:WaitForChild("MarsocScore").Text) > 2 or tonumber(mainFrame:WaitForChild("SpetsScore").Text) > 2 then
		wait(5);
		camera.CameraType = "Scriptable";
		ambience:Stop();
		menuMusic:Play();
		camera.CFrame = workspace:WaitForChild("CameraPos").CFrame;
		UserInputService.MouseIconEnabled = true;
		mainFrame:WaitForChild("MarsocScore").Text = 0;
		mainFrame:WaitForChild("SpetsScore").Text = 0;
	else
		wait(1);
		onClickPlay();
		wait(5);
		trainModel:SetPrimaryPartCFrame(defaultTrainPosition);
	end
end

local function updateKillFeed(killer, victim, killerTeam)
	for i = 1, #killFeedArray do
		killFeedArray[i].Position = killFeedArray[i].Position - UDim2.new(0, 0, .05, 0);
	end
	
	local thisKillFeed = killFeed:Clone();
	thisKillFeed.Parent = mainFrame;
	thisKillFeed.KFVictim.Text = victim;
	thisKillFeed.KFKiller.Text = killer;
	
	if killerTeam == player.Team then
		thisKillFeed.KFKiller.TextColor3 = Color3.new(0, 118, 191);
		thisKillFeed.KFVictim.TextColor3 = Color3.new(255, 0, 0);
	else
		thisKillFeed.KFKiller.TextColor3 = Color3.new(255, 0, 0);
		thisKillFeed.KFVictim.TextColor3 = Color3.new(0, 118, 191);
	end
	
	thisKillFeed.Visible = true;
	killFeedArray[#killFeedArray + 1] = thisKillFeed;
end

initializeGUI();

transition.Visible = true;
mainFrame.Visible = false;

playButton.MouseButton1Click:Connect(onClickPlay);
playButton.MouseEnter:Connect(onHover);
playButton.MouseLeave:Connect(onEndHover);

skillsButton.MouseButton1Click:Connect(onClickSkills);
skillsButton.MouseEnter:Connect(onHoverSkills);
skillsButton.MouseLeave:Connect(onEndHoverSkills);

backButton.MouseButton1Click:Connect(onClickBack);
backButton.MouseEnter:Connect(onHoverBack);
backButton.MouseLeave:Connect(onEndHoverBack);

skillTreeButton.MouseButton1Click:Connect(onClickSkillTree);

skillTreeBackButton.MouseButton1Click:Connect(onClickSkillTreeBack);
skillTreeBackButton.MouseEnter:Connect(onHoverSkillTreeBack);
skillTreeBackButton.MouseLeave:Connect(onHoverEndSkillTreeBack);

repInitializeRemote.OnClientEvent:Connect(initializeGame);
repEndMatchRemote.OnClientEvent:Connect(endMatch);

buySPButton.MouseEnter:Connect(onHoverBuySP);
buySPButton.MouseLeave:Connect(onEndHoveBuySP);
buySPButton.MouseButton1Click:Connect(buySPClick);

instantiateWeaponButtons();
instantiateSkillButtons();
updateStatsTree("startup");
selectWeapon(weapons:WaitForChild("UMP .45"));

updateKillFeedRemote.OnClientEvent:Connect(updateKillFeed);

local contentProvider = game:GetService("ContentProvider");

transition:WaitForChild("Waiting").Text = "Loading Assets";

repeat
	
	wait();
	
until contentProvider.RequestQueueSize < 5;

for i = 0, 1, .02 do
	
	transition.BackgroundTransparency = i;
	transition:WaitForChild("LoadingScreen").ImageTransparency = i + .1;
	RunService.Heartbeat:Wait();
	
end

transition.Visible = false;

-- \\ Begin Menu //--