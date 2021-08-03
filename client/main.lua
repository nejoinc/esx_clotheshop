ESX = nil
local GUI, CurrentActionData = {}, {}
GUI.Time = 0
local LastZone, CurrentAction, CurrentActionMsg
local HasPayed, HasLoadCloth, HasAlreadyEnteredMarker = false, false, false

Citizen.CreateThread(function()

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)



Citizen.CreateThread(function()
    local clothes = {
		`prop_till_01`
    }

    exports['bt-target']:AddTargetModel(clothes, {
        options = {
            {
                event = 'esx_clotheshop:Menu',
                icon = 'fas fa-tshirt',
                label = "Open Clothes Shop"
            },
        },
        job = {'all'},
        distance = 2.5
    })
end)

function OpenShopMenu()
  local elements = {}

  table.insert(elements, {label = _U('shop_clothes'),  value = 'shop_clothes'})
  table.insert(elements, {label = _U('player_clothes'), value = 'player_dressing'})
  table.insert(elements, {label = _U('suppr_cloth'), value = 'suppr_cloth'})

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_main', {
      title    = _U('shop_main_menu'),
      align    = 'top-left',
      elements = elements,
    }, function(data, menu)
	menu.close()

      if data.current.value == 'shop_clothes' then
			HasPayed = false

	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)

		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
				title = _U('valid_this_purchase'),
				align = 'top-left',
				elements = {
					{label = _U('yes'), value = 'yes'},
					{label = _U('no'), value = 'no'},
				}
			}, function(data, menu)

				menu.close()

				if data.current.value == 'yes' then

					ESX.TriggerServerCallback('esx_clotheshop:checkMoney', function(hasEnoughMoney)

						if hasEnoughMoney then

							TriggerEvent('skinchanger:getSkin', function(skin)
								TriggerServerEvent('esx_skin:save', skin)
							end)

							TriggerServerEvent('esx_clotheshop:pay')

							HasPayed = true

							ESX.TriggerServerCallback('esx_clotheshop:checkPropertyDataStore', function(foundStore)

								if foundStore then

									ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'save_dressing', {
											title = _U('save_in_dressing'),
											align = 'top-left',
											elements = {
												{label = _U('yes'), value = 'yes'},
												{label = _U('no'),  value = 'no'},
											}
										}, function(data2, menu2)

											menu2.close()

											if data2.current.value == 'yes' then

												ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'outfit_name', {
														title = _U('name_outfit'),
													}, function(data3, menu3)

														menu3.close()

														TriggerEvent('skinchanger:getSkin', function(skin)
															TriggerServerEvent('esx_clotheshop:saveOutfit', data3.value, skin)
														end)

														ESX.ShowNotification(_U('saved_outfit'))

													end, function(data3, menu3)
														menu3.close()
													end)
											end
										end)
								end
							end)

						else

							TriggerEvent('esx_skin:getLastSkin', function(skin)
								TriggerEvent('skinchanger:loadSkin', skin)
							end)

							ESX.ShowNotification(_U('not_enough_money'))
						end
					end)
				end

				if data.current.value == 'no' then

					TriggerEvent('esx_skin:getLastSkin', function(skin)
						TriggerEvent('skinchanger:loadSkin', skin)
					end)
				end

			--	CurrentAction     = 'shop_menu'
		--		CurrentActionMsg  = _U('press_menu')
		--		CurrentActionData = {}
--
			end, function(data, menu)

				menu.close()

			--	CurrentAction     = 'shop_menu'
			--	CurrentActionMsg  = _U('press_menu')
		--		CurrentActionData = {}

			end)
	end, function(data, menu)

			menu.close()

			CurrentAction     = 'shop_menu'
			CurrentActionMsg  = _U('press_menu')
			CurrentActionData = {}

	end, {
		'tshirt_1',
		'tshirt_2',
		'torso_1',
		'torso_2',
		'decals_1',
		'decals_2',
		'arms',
		'pants_1',
		'pants_2',
		'shoes_1',
		'shoes_2',
		'chain_1',
		'chain_2',
		'helmet_1',
		'helmet_2',
		'glasses_1',
		'glasses_2',
		'bags_1',
		'bags_2',
	})
      end

      if data.current.value == 'player_dressing' then
		
        ESX.TriggerServerCallback('esx_clotheshop:getPlayerDressing', function(dressing)
          local elements = {}

          for i=1, #dressing, 1 do
            table.insert(elements, {label = dressing[i], value = i})
          end

          ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
              title    = _U('player_clothes'),
              align    = 'top-left',
              elements = elements,
            }, function(data, menu)

              TriggerEvent('skinchanger:getSkin', function(skin)

                ESX.TriggerServerCallback('esx_clotheshop:getPlayerOutfit', function(clothes)

                  TriggerEvent('skinchanger:loadClothes', skin, clothes)
                  TriggerEvent('esx_skin:setLastSkin', skin)

                  TriggerEvent('skinchanger:getSkin', function(skin)
                    TriggerServerEvent('esx_skin:save', skin)
                  end)
				  
				  ESX.ShowNotification(_U('loaded_outfit'))
				  HasLoadCloth = true
                end, data.current.value)
              end)
            end, function(data, menu)
              menu.close()
			  
			  CurrentAction     = 'shop_menu'
			  CurrentActionMsg  = _U('press_menu')
			  CurrentActionData = {}
            end
          )
        end)
      end
	  
	  if data.current.value == 'suppr_cloth' then
		ESX.TriggerServerCallback('esx_clotheshop:getPlayerDressing', function(dressing)
			local elements = {}

			for i=1, #dressing, 1 do
				table.insert(elements, {label = dressing[i], value = i})
			end
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'supprime_cloth', {
              title    = _U('suppr_cloth'),
              align    = 'top-left',
              elements = elements,
            }, function(data, menu)
			menu.close()
				TriggerServerEvent('esx_clotheshop:deleteOutfit', data.current.value)
				  
				ESX.ShowNotification(_U('supprimed_cloth'))

            end, function(data, menu)
              menu.close()
			  
			  CurrentAction     = 'shop_menu'
			  CurrentActionMsg  = _U('press_menu')
			  CurrentActionData = {}
            end)
		end)
	  end
    end, function(data, menu)

      menu.close()

      CurrentAction     = 'room_menu'
      CurrentActionMsg  = _U('press_menu')
      CurrentActionData = {}
    end)
end

RegisterNetEvent("esx_clotheshop:Menu")
AddEventHandler("esx_clotheshop:Menu", function()
    OpenShopMenu("clothesmenu")
end)

AddEventHandler('esx_clotheshop:hasEnteredMarker', function(zone)
	CurrentAction     = 'shop_menu'
	CurrentActionMsg  = _U('press_menu')
	CurrentActionData = {}
end)

AddEventHandler('esx_clotheshop:hasExitedMarker', function(zone)
	
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil

	if not HasPayed then
		if not HasLoadCloth then 

			TriggerEvent('esx_skin:getLastSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()

	for i=1, #Config.Shops, 1 do

		local blip = AddBlipForCoord(Config.Shops[i].x, Config.Shops[i].y, Config.Shops[i].z)

		SetBlipSprite (blip, 73)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.5)
		SetBlipColour (blip, 47)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('clothes'))
		EndTextCommandSetBlipName(blip)
	end
end)






