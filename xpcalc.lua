local function ROUND(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function HasWarMode()
  local i = 1
  local hasWarMode = false

  while true do
    local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)

    if spellName == 'War Mode' then
      hasWarMode = true
      do break end
    end

    if not spellName then
      do break end
    end

    i = i + 1
  end

  return hasWarMode
end

local function GetXpRewardModifiedByCharLevel(qLevel, qExp, cLevel, cWarMode)
  local WAR_MODE_XP_MODIFIER = 1.3
  local QUEST_DECAY_LEVEL_GAP = 24
  if cLevel >= qLevel + QUEST_DECAY_LEVEL_GAP then qExp = 0 end

  if cWarMode == true then
    return qExp * WAR_MODE_XP_MODIFIER
  end

  return qExp
end

local function GetQuestReward(qId, qTitle, qLevel)
  local cLevel = UnitLevel('player')

  if cLevel < 60 then
    local questDB = pfQuest_turtle_quest_xp
    local candidate = questDB[qId]
    local rawXP = 0
    local hasWarMode = HasWarMode()

    if candidate then 
      if candidate.title == qTitle and candidate.questLevel == qLevel then
        rawXP = candidate.rewXP
      end
    else
      for _,v in pairs(questDB) do
        if v.title == qTitle and v.questLevel == qLevel then
          rawXP = v.rewXP
          do break end
        end
      end
    end

    if rawXP == 0 then return "" end
    return '(' .. tostring(GetXpRewardModifiedByCharLevel(qLevel, rawXP, cLevel, hasWarMode)) .. ' xp)'
  else
    return ""
  end
end

function pfQuest_turtle_GetQuestRewardById(qId, qTitle, qLevel)
  return GetQuestReward(qId, qTitle, qLevel)
end