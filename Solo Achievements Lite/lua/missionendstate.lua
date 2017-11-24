Hooks:PostHook(MissionEndState, "on_statistics_result", "MissionEndState_on_statistics_result_SoloAchievementsLite", function (self)
	if Global.game_settings.single_player then
		local SAL_complete_heist_statistics_achievements = {
			immortal_ballot = tweak_data.achievement.complete_heist_statistics_achievements.immortal_ballot,
			full_two_twenty = tweak_data.achievement.complete_heist_statistics_achievements.full_two_twenty
		}
		SAL_complete_heist_statistics_achievements.immortal_ballot.num_players = 1 -- Reputation Beyond Reproach
		SAL_complete_heist_statistics_achievements.full_two_twenty.num_players = 1 -- 120 Proof

		local level_id, all_pass, total_kill_pass, total_accuracy_pass, total_headshots_pass, total_downed_pass, level_pass, levels_pass, num_players_pass, diff_pass, is_dropin_pass, success_pass = nil

		for achievement, achievement_data in pairs(SAL_complete_heist_statistics_achievements or {}) do
			level_id = managers.job:has_active_job() and managers.job:current_level_id() or ""
			diff_pass = not achievement_data.difficulty or table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
			num_players_pass = not achievement_data.num_players or achievement_data.num_players <= managers.network:session():amount_of_players()
			level_pass = not achievement_data.level_id or achievement_data.level_id == level_id
			levels_pass = not achievement_data.levels or table.contains(achievement_data.levels, level_id)
			total_kill_pass = not achievement_data.total_kills or achievement_data.total_kills <= total_kills
			total_accuracy_pass = not achievement_data.total_accuracy or achievement_data.total_accuracy <= group_accuracy
			total_downed_pass = not achievement_data.total_downs or group_downs <= achievement_data.total_downs
			is_dropin_pass = achievement_data.is_dropin == nil or achievement_data.is_dropin == managers.statistics:is_dropin()
			success_pass = not achievement_data.success or self._success

			if achievement_data.total_headshots then
				total_headshots_pass = (not achievement_data.total_headshots.invert or total_head_shots <= (achievement_data.total_headshots.amount or 0)) and (achievement_data.total_headshots.amount or 0) <= total_head_shots
			else
				total_headshots_pass = true
			end

			all_pass = diff_pass and num_players_pass and level_pass and levels_pass and total_kill_pass and total_accuracy_pass and total_downed_pass and is_dropin_pass and total_headshots_pass and managers.challenge:check_equipped(achievement_data) and managers.challenge:check_equipped_team(achievement_data) and success_pass

			if all_pass and not managers.achievment:award_data(achievement_data) then
				Application:debug("[MissionEndState] complete_heist_achievements:", achievement)
			end
		end
	end
end)

Hooks:PostHook(MissionEndState, "chk_complete_heist_achievements", "MissionEndState_chk_complete_heist_achievements_SoloAchievementsLite", function (self)
	if self._success and Global.game_settings.single_player then
		if not managers.statistics:is_dropin() then
			local SAL_complete_heist_achievements = {
				pain_train = tweak_data.achievement.complete_heist_achievements.pain_train,
				anticimex = tweak_data.achievement.complete_heist_achievements.anticimex,
				ovk_8 = tweak_data.achievement.complete_heist_achievements.ovk_8,
				steel_1 = tweak_data.achievement.complete_heist_achievements.steel_1,
				green_2 = tweak_data.achievement.complete_heist_achievements.green_2
			}
			SAL_complete_heist_achievements.pain_train.num_players = 1 -- Here Comes the Pain Train
			SAL_complete_heist_achievements.anticimex.num_players = 1 -- Cooking With Style
			SAL_complete_heist_achievements.ovk_8.num_players = 1 -- Boston Saints
			SAL_complete_heist_achievements.steel_1.num_players = 1 -- Heisters of the Round Table
			SAL_complete_heist_achievements.green_2.num_players = 1 -- Original Heisters

			local mask_pass, diff_pass, no_shots_pass, contract_pass, job_pass, jobs_pass, level_pass, levels_pass, stealth_pass, loud_pass, equipped_pass, job_value_pass, phalanx_vip_alive_pass, used_weapon_category_pass, equipped_team_pass, timer_pass, num_players_pass, pass_skills, killed_by_weapons_pass, killed_by_melee_pass, killed_by_grenade_pass, civilians_killed_pass, complete_job_pass, memory_pass, is_host_pass, character_pass, converted_cops_pass, total_accuracy_pass, weapons_used_pass, everyone_killed_by_weapons_pass, everyone_killed_by_melee_pass, everyone_killed_by_grenade_pass, everyone_weapons_used_pass, enemy_killed_pass, everyone_used_weapon_category_pass, everyone_killed_by_weapon_category_pass, everyone_killed_by_projectile_pass, killed_pass, shots_by_weapon_pass, killed_by_blueprint_pass, mutators_pass, secured_pass, crime_spree_pass, all_pass, weapon_data, memory, level_id, stage, num_skills = nil
			local phalanx_vip_alive = false

			for _, enemy in pairs(managers.enemy:all_enemies() or {}) do
				phalanx_vip_alive = alive(enemy.unit) and enemy.unit:base()._tweak_table == "phalanx_vip"

				if phalanx_vip_alive then
					break
				end
			end

			for achievement, achievement_data in pairs(SAL_complete_heist_achievements) do
				level_id = managers.job:has_active_job() and managers.job:current_level_id() or ""
				diff_pass = not achievement_data.difficulty or table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
				mask_pass = not achievement_data.mask or managers.blackmarket:equipped_mask().mask_id == achievement_data.mask
				job_pass = not achievement_data.job or managers.statistics:started_session_from_beginning() and (managers.job:on_last_stage() or achievement_data.need_full_job) and managers.job:current_real_job_id() == achievement_data.job
				jobs_pass = not achievement_data.jobs or managers.statistics:started_session_from_beginning() and (managers.job:on_last_stage() or achievement_data.need_full_job) and table.contains(achievement_data.jobs, managers.job:current_real_job_id())
				level_pass = not achievement_data.level_id or achievement_data.level_id == level_id
				levels_pass = not achievement_data.levels or table.contains(achievement_data.levels, level_id)
				contract_pass = not achievement_data.contract or managers.job:current_contact_id() == achievement_data.contract
				complete_job_pass = not achievement_data.complete_job or managers.statistics:started_session_from_beginning() and managers.job:on_last_stage()
				no_shots_pass = not achievement_data.no_shots or managers.statistics:session_total_shots(achievement_data.no_shots) == 0
				stealth_pass = not achievement_data.stealth or managers.groupai and managers.groupai:state():whisper_mode()
				loud_pass = not achievement_data.loud or managers.groupai and not managers.groupai:state():whisper_mode()
				timer_pass = not achievement_data.timer or managers.game_play_central and managers.game_play_central:get_heist_timer() <= achievement_data.timer
				num_players_pass = not achievement_data.num_players or achievement_data.num_players <= managers.network:session():amount_of_players()
				job_value_pass = not achievement_data.job_value or managers.mission:get_job_value(achievement_data.job_value.key) == achievement_data.job_value.value
				memory_pass = not achievement_data.memory or managers.job:get_memory(achievement, achievement_data.memory.is_shortterm) == achievement_data.memory.value
				phalanx_vip_alive_pass = not achievement_data.phalanx_vip_alive or phalanx_vip_alive
				is_host_pass = not achievement_data.is_host or Network:is_server() or Global.game_settings.single_player
				converted_cops_pass = not achievement_data.converted_cops or achievement_data.converted_cops <= managers.groupai:state():get_amount_enemies_converted_to_criminals()
				total_accuracy_pass = not achievement_data.total_accuracy or achievement_data.total_accuracy <= managers.statistics:session_hit_accuracy()
				enemy_killed_pass = not achievement_data.killed

				if achievement_data.killed then
					enemy_killed_pass = true

					for enemy, count in pairs(achievement_data.killed) do
						local num_killed = managers.statistics:session_enemy_killed_by_type(enemy, "count")

						if count == 0 then
							enemy_killed_pass = num_killed == 0
						else
							enemy_killed_pass = count <= num_killed
						end

						if not enemy_killed_pass then
							break
						end
					end
				end

				killed_pass = not achievement_data.anyone_killed

				if achievement_data.anyone_killed then
					local num_killed = managers.statistics:session_total_kills_by_anyone()

					if achievement_data.anyone_killed == 0 then
						killed_pass = num_killed == 0
					else
						killed_pass = achievement_data.anyone_killed <= num_killed
					end
				end

				mutators_pass = managers.mutators:check_achievements(achievement_data)
				used_weapon_category_pass = true

				if achievement_data.used_weapon_category then
					local used_weapons = managers.statistics:session_used_weapons()

					if used_weapons then
						local category = achievement_data.used_weapon_category
						local weapon_tweak = nil

						for _, weapon_id in ipairs(used_weapons) do
							weapon_tweak = tweak_data.weapon[weapon_id]

							if not weapon_tweak or not table.contains(weapon_tweak.categories, category) then
								used_weapon_category_pass = false

								break
							end
						end
					end
				end

				everyone_used_weapon_category_pass = true

				if achievement_data.everyone_used_weapon_category and managers.statistics:session_anyone_used_weapon_category_except(achievement_data.everyone_used_weapon_category) then
					everyone_used_weapon_category_pass = false
				end

				everyone_killed_by_weapon_category_pass = true

				if achievement_data.everyone_killed_by_weapon_category and managers.statistics:session_anyone_killed_by_weapon_category_except(achievement_data.everyone_killed_by_weapon_category) > 0 then
					everyone_killed_by_weapon_category_pass = false
				end

				killed_by_weapons_pass = not achievement_data.killed_by_weapons

				if achievement_data.killed_by_weapons then
					if achievement_data.killed_by_weapons == 0 then
						killed_by_weapons_pass = killed_by_weapons == 0
					else
						killed_by_weapons_pass = achievement_data.killed_by_weapons <= killed_by_weapons
					end
				end

				everyone_killed_by_weapons_pass = not achievement_data.everyone_killed_by_weapons

				if achievement_data.everyone_killed_by_weapons then
					local everyone_killed_by_weapons = managers.statistics:session_anyone_killed_by_weapons()

					if achievement_data.everyone_killed_by_weapons == 0 then
						everyone_killed_by_weapons_pass = everyone_killed_by_weapons == 0
					else
						everyone_killed_by_weapons_pass = achievement_data.everyone_killed_by_weapons <= everyone_killed_by_weapons
					end
				end

				killed_by_melee_pass = not achievement_data.killed_by_melee

				if achievement_data.killed_by_melee then
					if achievement_data.killed_by_melee == 0 then
						killed_by_melee_pass = killed_by_melee == 0
					else
						killed_by_melee_pass = achievement_data.killed_by_melee <= killed_by_melee
					end
				end

				everyone_killed_by_melee_pass = not achievement_data.everyone_killed_by_melee

				if achievement_data.everyone_killed_by_melee then
					local everyone_killed_by_melee = managers.statistics:session_anyone_killed_by_melee()

					if achievement_data.everyone_killed_by_melee == 0 then
						everyone_killed_by_melee_pass = everyone_killed_by_melee == 0
					else
						everyone_killed_by_melee_pass = achievement_data.everyone_killed_by_melee <= everyone_killed_by_melee
					end
				end

				killed_by_grenade_pass = not achievement_data.killed_by_grenade

				if achievement_data.killed_by_grenade then
					if achievement_data.killed_by_grenade == 0 then
						killed_by_grenade_pass = killed_by_grenade == 0
					else
						killed_by_grenade_pass = achievement_data.killed_by_grenade <= killed_by_grenade
					end
				end

				everyone_killed_by_grenade_pass = not achievement_data.everyone_killed_by_grenade

				if achievement_data.everyone_killed_by_grenade then
					local everyone_killed_by_grenade = managers.statistics:session_anyone_killed_by_grenade()

					if achievement_data.everyone_killed_by_grenade == 0 then
						everyone_killed_by_grenade_pass = everyone_killed_by_grenade == 0
					else
						everyone_killed_by_grenade_pass = achievement_data.everyone_killed_by_grenade <= everyone_killed_by_grenade
					end
				end

				everyone_killed_by_projectile_pass = not achievement_data.everyone_killed_by_projectile

				if achievement_data.everyone_killed_by_projectile and #achievement_data.everyone_killed_by_projectile > 1 then
					local everyone_killed_by_projectile = managers.statistics:session_anyone_killed_by_projectile(achievement_data.everyone_killed_by_projectile[1])

					if achievement_data.everyone_killed_by_projectile[2] == 0 then
						everyone_killed_by_projectile_pass = everyone_killed_by_projectile == 0
					else
						everyone_killed_by_projectile_pass = achievement_data.everyone_killed_by_projectile[2] <= everyone_killed_by_projectile
					end
				end

				civilians_killed_pass = not achievement_data.civilians_killed

				if achievement_data.civilians_killed then
					if achievement_data.civilians_killed == 0 then
						civilians_killed_pass = civilians_killed == 0
					else
						civilians_killed_pass = achievement_data.civilians_killed <= civilians_killed
					end
				end

				weapons_used_pass = not achievement_data.weapons_used

				if achievement_data.weapons_used then
					weapons_used_pass = managers.statistics:session_killed_by_weapons_except(achievement_data.weapons_used) == 0
				end

				everyone_weapons_used_pass = not achievement_data.everyone_weapons_used

				if achievement_data.everyone_weapons_used then
					everyone_weapons_used_pass = managers.statistics:session_anyone_killed_by_weapons_except(achievement_data.everyone_weapons_used) == 0
				end

				shots_by_weapon_pass = not achievement_data.shots_by_weapon

				if achievement_data.shots_by_weapon then
					shots_by_weapon_pass = not managers.statistics:session_anyone_used_weapon_except(achievement_data.shots_by_weapon)
				end

				secured_pass = not achievement_data.secured

				if achievement_data.secured then
					if achievement_data.secured[1] ~= nil then
						for i, secured_data in ipairs(achievement_data.secured) do
							secured_pass = managers.loot:_check_secured(achievement, secured_data)

							if not secured_pass then
								break
							end
						end
					else
						secured_pass = managers.loot:_check_secured(achievement, achievement_data.secured)
					end
				end

				crime_spree_pass = not achievement_data.crime_spree

				if achievement_data.crime_spree then
					if type(achievement_data.crime_spree) == "number" then
						crime_spree_pass = managers.crime_spree:is_active() and achievement_data.crime_spree <= managers.crime_spree:spree_level()
					else
						crime_spree_pass = managers.crime_spree:is_active()
					end
				end

				pass_skills = not achievement_data.num_skills

				if not pass_skills then
					num_skills = 0

					for tree, data in ipairs(tweak_data.skilltree.trees) do
						local points = managers.skilltree:get_tree_progress(tree)
						num_skills = num_skills + points
					end

					pass_skills = num_skills <= achievement_data.num_skills
				end

				character_pass = not achievement_data.characters

				if achievement_data.characters then
					character_pass = true

					for _, character_name in ipairs(achievement_data.characters) do
						local found = false

						for _, peer in pairs(managers.network:session():all_peers()) do
							if not peer:is_dropin() and peer:character() == character_name then
								found = true

								break
							end
						end

						if not found then
							character_pass = false

							break
						end
					end
				end

				equipped_pass = not achievement_data.equipped or false

				if achievement_data.equipped then
					for category, data in pairs(achievement_data.equipped) do
						weapon_data = managers.blackmarket:equipped_item(category)

						if (category == "grenades" or category == "armors") and data == weapon_data then
							equipped_pass = true
						elseif weapon_data and weapon_data.weapon_id and (data.weapon_id and data.weapon_id == weapon_data.weapon_id or data.category and data.category == tweak_data:get_raw_value("weapon", weapon_data.weapon_id, "categories", 1)) then
							equipped_pass = true

							if data.blueprint and weapon_data.blueprint then
								for _, part_or_parts in ipairs(data.blueprint) do
									if type(part_or_parts) == "string" then
										if not table.contains(weapon_data.blueprint, part_or_parts) then
											equipped_pass = false

											break
										end
									else
										local found_one = false

										for _, part_id in ipairs(part_or_parts) do
											if table.contains(weapon_data.blueprint, part_id) then
												found_one = true

												break
											end
										end

										if not found_one then
											equipped_pass = false

											break
										end
									end
								end
							end

							if data.blueprint_part_data and weapon_data.blueprint then
								for key, req_value in pairs(data.blueprint_part_data) do
									local found_one = false

									for i, part_id in ipairs(weapon_data.blueprint) do
										local part_data = tweak_data.weapon.factory.parts[part_id]

										if part_data then
											if type(req_value) == "table" then
												if table.contains(req_value, part_data[key]) then
													found_one = true

													break
												end
											elseif part_data[key] == req_value then
												found_one = true

												break
											end
										end
									end

									if not found_one then
										equipped_pass = false

										break
									end
								end
							end
						end
					end
				end

				if achievement_data.equipped_outfit then
					equipped_pass = managers.challenge:check_equipped(achievement_data)
				end

				killed_by_blueprint_pass = not achievement_data.killed_by_blueprint or false

				if achievement_data.killed_by_blueprint then
					local blueprint = achievement_data.killed_by_blueprint.blueprint
					local amount = achievement_data.killed_by_blueprint.amount
					local weapons_to_check = {
						managers.blackmarket:equipped_primary(),
						managers.blackmarket:equipped_secondary()
					}

					for _, weapon_data in ipairs(weapons_to_check) do
						if weapon_data then
							local weapon_id = weapon_data.weapon_id
							local weapon_amount = managers.statistics:session_killed_by_weapon(weapon_id)

							if amount == 0 and weapon_amount == 0 or amount > 0 and amount <= weapon_amount then
								local missing_parts = false
								local weapon_blueprint = weapon_data.blueprint or {}

								if type(blueprint) == "string" then
									if not table.contains(weapon_blueprint, blueprint) then
										missing_parts = true
									end
								else
									for _, part in ipairs(blueprint) do
										if type(part) == "string" then
											if not table.contains(weapon_blueprint, part) then
												missing_parts = true

												break
											end
										else
											local found_parts = false

											for _, or_part in ipairs(part) do
												if table.contains(weapon_blueprint, or_part) then
													found_parts = true
												end
											end

											if not found_parts then
												missing_parts = true
											end
										end
									end
								end

								if not missing_parts then
									killed_by_blueprint_pass = true

									break
								end
							end
						end
					end
				end

				equipped_team_pass = managers.challenge:check_equipped(achievement_data) and managers.challenge:check_equipped_team(achievement_data)
				all_pass = job_pass and jobs_pass and level_pass and levels_pass and contract_pass and diff_pass and mask_pass and no_shots_pass and stealth_pass and loud_pass and equipped_pass and equipped_team_pass and num_players_pass and pass_skills and timer_pass and killed_by_weapons_pass and killed_by_melee_pass and killed_by_grenade_pass and complete_job_pass and job_value_pass and memory_pass and phalanx_vip_alive_pass and used_weapon_category_pass and is_host_pass and character_pass and converted_cops_pass and total_accuracy_pass and weapons_used_pass and everyone_killed_by_weapons_pass and everyone_killed_by_melee_pass and everyone_killed_by_grenade_pass and everyone_weapons_used_pass and everyone_used_weapon_category_pass and enemy_killed_pass and everyone_killed_by_weapon_category_pass and everyone_killed_by_projectile_pass and killed_pass and shots_by_weapon_pass and killed_by_blueprint_pass and mutators_pass and secured_pass and crime_spree_pass

				if all_pass and achievement_data.need_full_job and managers.job:has_active_job() then
					memory = managers.job:get_memory(achievement)

					if not managers.job:interupt_stage() then
						if not memory then
							memory = {}

							for i = 1, #managers.job:current_job_chain_data(), 1 do
								memory[i] = false
							end
						end

						stage = managers.job:current_stage()
						memory[stage] = not not all_pass

						managers.job:set_memory(achievement, memory)

						if managers.job:on_last_stage() then
							for stage, passed in pairs(memory) do
								if not passed then
									all_pass = false

									break
								end
							end
						else
							all_pass = false
						end
					elseif managers.job:on_last_stage() then
						for stage, passed in pairs(memory or {}) do
							if not passed then
								all_pass = false

								break
							end
						end
					else
						all_pass = false
					end
				end

				if achievement_data.need_full_stealth then
					local stealth_memory = managers.job:get_memory("stealth")
					local in_stealth = managers.groupai and managers.groupai:state():whisper_mode()

					if stealth_memory == nil then
						stealth_memory = in_stealth == nil and true or in_stealth
					end

					if not in_stealth and stealth_memory then
						stealth_memory = false

						managers.job:set_memory("stealth", stealth_memory)
					end

					if managers.job:on_last_stage() and not stealth_memory then
						all_pass = false
					end
				end

				if all_pass then
					managers.achievment:_award_achievement(achievement_data, achievement)
				end
			end
		end

		-- Reindeer Games, Ghost Riders, Funding Father, Four Monkeys, Sounds of Animals Fighting, Unusual Suspects, Wind of Change, Riders On the Snowstorm and Honor Among Thieves
		local masks_pass, level_pass, job_pass, jobs_pass, difficulty_pass, difficulties_pass, all_pass, memory, level_id, stage = nil
		local num_plrs = managers.network:session():amount_of_players()

		for achievement, achievement_data in pairs(tweak_data.achievement.four_mask_achievements) do
			level_id = managers.job:has_active_job() and managers.job:current_level_id() or ""
			masks_pass = not not achievement_data.masks
			level_pass = not achievement_data.level_id or achievement_data.level_id == level_id
			job_pass = not achievement_data.job or managers.statistics:started_session_from_beginning() and managers.job:on_last_stage() and managers.job:current_real_job_id() == achievement_data.job
			jobs_pass = not achievement_data.jobs or managers.statistics:started_session_from_beginning() and managers.job:on_last_stage() and table.contains(achievement_data.jobs, managers.job:current_real_job_id())
			difficulty_pass = not achievement_data.difficulty or Global.game_settings.difficulty == achievement_data.difficulty
			difficulties_pass = not achievement_data.difficulties or table.contains(achievement_data.difficulties, Global.game_settings.difficulty)
			all_pass = masks_pass and level_pass and job_pass and jobs_pass and difficulty_pass and difficulties_pass

			if all_pass then
				local available_masks = deep_clone(achievement_data.masks)
				local all_masks_valid = true
				local valid_mask_count = 0

				for _, peer in pairs(managers.network:session():all_peers()) do
					local current_mask = peer:mask_id()

					if table.contains(available_masks, current_mask) then
						table.delete(available_masks, current_mask)

						valid_mask_count = valid_mask_count + 1
					else
						all_masks_valid = false
					end
				end

				all_masks_valid = all_masks_valid and valid_mask_count >= num_plrs

				if all_masks_valid then
					managers.achievment:award_data(achievement_data)
				end
			end
		end
	end

	managers.achievment:clear_heist_success_awards()
end)