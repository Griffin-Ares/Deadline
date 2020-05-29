		local function raycast(gunModel, damage)
			local ray = Ray.new(camera.CFrame.p, ((camera.CFrame * CFrame.new(0, 0, -50).p) - camera.CFrame.p).unit * 300);
			local hitPart, hitPos, hitNorm = workspace:FindPartOnRay(ray, player.Character, false, true);
			
			--local distance = (glock.firePart.CFrame.p - hitPos).magnitude;
					
			if hitPart then
				local shotDamage = currentGun.damage; --this placed if needed in future
				repDamageRemote:FireServer(hitPart, shotDamage, hitPos, hitNorm, (camera.CFrame * CFrame.new(0, 0, -100).p), currentGun.firePart.Position); --player, part, damage, position, normal, startPos
				if hitPart.Parent and string.find(hitPart.Parent.Name, "Ragdoll") == nil and (string.find(hitPart.Parent.Name, "Spetsnaz") or string.find(hitPart.Parent.Name, "MARSOC")) then
					if hitPart.Parent:FindFirstChild("Humanoid").Health - damage > 0 then
						local hitFleshClone = hitFlesh:Clone();
						hitFleshClone.PlaybackSpeed = math.random(90, 110)/100;
						hitFleshClone.Parent = thisChar:WaitForChild("Head");
						hitFleshClone:Destroy();
					end
				end
			end
			
		end
		
		local lastTick = tick();
		
		local function fireWeapon()
			if (tick() - lastTick) > 60/currentGun.fireRate and currentGun.currentMag > 0 and reloading == false and equipping == false then
					currentGun.currentMag = currentGun.currentMag - 1;
					lastTick = tick();
					repShotRemote:FireServer(thisChar:WaitForChild(currentGun.ThirdPersonClone));
					local muzzleFX = currentGun.firePart:GetChildren();
					for i = 1, #muzzleFX do
						muzzleFX[i].Enabled = true;
					end
					currentGun.shootAnim:Play(.1, .95, 2.25);
					raycast(currentGun.clone, currentGun.damage);
					local cHSoundClone = casingHit:Clone();
					--cHSoundClone.Parent = glock17FireSound.Parent;
					--cHSoundClone.PlaybackSpeed = math.random(90, 100)/100;
					--cHSoundClone:Destroy();
					--ejectShell(currentGun.clone.Shell);
					if hasSteadyAim and thisChar.HumanoidRootPart.Velocity.Magnitude < 1 then
						recoil(currentGun.recoil * .8);
					else
						recoil(currentGun.recoil);		
					end
					for i = 1, #muzzleFX do
						muzzleFX[i].Enabled = false;
					end
					print(tick()-lastTick)
				else
					if currentGun.currentMag < 1 then
						local eSoundClone = noBullet:Clone();
						eSoundClone.Parent = glock17FireSound.Parent;
						eSoundClone.PlaybackSpeed = math.random(90, 100)/100;
						eSoundClone:Play();
						wait(3);
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
			end
		end
		
		