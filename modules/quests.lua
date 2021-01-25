local addonName, AltManager = ...

local function GetCurrentTier(talents)
	local currentTier = 0;
	for i, talentInfo in ipairs(talents) do
		if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave then
			currentTier = currentTier + 1;
		end
	end
	return currentTier;
end

function AltManager:UpdateQuest(questID)
	if not questID then return end
	local char_table = self.validateData()
	if not char_table then return end
	if not char_table.questInfo then self:UpdateAllQuests() end

	local foundResetKey, key
	for resetKey, quests in pairs(self.quests) do
		if quests[questID] then
			foundResetKey = resetKey
			key = quests[questID].key
			break
		end
	end

	if foundResetKey and key and char_table.questInfo[foundResetKey][key] then
		char_table.questInfo[foundResetKey][key][questID] = true
	end
end

function AltManager:UpdateAllQuests()
	local char_table = self.validateData()
	if not char_table then return end

	local covenant = char_table.covenant or C_Covenants.GetActiveCovenantID()
	local questInfo = {}
	for reset, quests in pairs(self.quests) do
		questInfo[reset] = {}
		for questID, info in pairs(quests) do
			if info.covenant and covenant == info.covenant then
				local sanctumTier
				if info.sanctum and char_table.sanctumInfo then
					sanctumTier = char_table.sanctumInfo[info.sanctum] and char_table.sanctumInfo[info.sanctum].tier or 0
					questInfo["max" .. info.key] = max(1, sanctumTier)
				end

				if not info.sanctum or (sanctumTier >= info.minSanctumTier) then
					questInfo[reset][info.key] = questInfo[reset][info.key] or {}
					questInfo[reset][info.key][questID] = C_QuestLog.IsQuestFlaggedCompleted(questID)
				end
			elseif not info.covenant then
				questInfo[reset][info.key] = questInfo[reset][info.key] or {}
				questInfo[reset][info.key][questID] = C_QuestLog.IsQuestFlaggedCompleted(questID)
			end
		end
	end

	questInfo.maxMawQuests = C_QuestLog.IsQuestFlaggedCompleted(60284) and 3 or 2
	char_table.questInfo = questInfo
end