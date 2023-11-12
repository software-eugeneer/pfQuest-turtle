local questDB = pfQuest_turtle_quest_xp
local WAR_MODE_XP_MODIFIER = 1.3

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
  local preWarModeExp
  if cLevel <= qLevel +  5 then preWarModeExp = qExp
  elseif cLevel == qLevel +  6 then preWarModeExp = ROUND(qExp * 0.8 / 5) * 5
  elseif cLevel == qLevel +  7 then preWarModeExp = ROUND(qExp * 0.6 / 5) * 5
  elseif cLevel == qLevel +  8 then preWarModeExp = ROUND(qExp * 0.4 / 5) * 5
  elseif cLevel == qLevel +  9 then preWarModeExp = ROUND(qExp * 0.2 / 5) * 5
  elseif cLevel >= qLevel +  10 then preWarModeExp = ROUND(qExp * 0.1 / 5) * 5
  else
    DEFAULT_CHAT_FRAME:AddMessage('Someting went wrong while calculating XP: [qLevel=' .. tostring(qLevel)  .. ', qExp=' .. tostring(qExp) .. ', cLevel=' .. tostring(cLevel) .. ', cWarMode=' .. tostring(cWarMode) .. ']')
  end

  if cWarMode == true then
    return preWarModeExp * WAR_MODE_XP_MODIFIER
  end

  return preWarModeExp
end

local function GetQuestReward(qId, qTitle, qLevel)
  local cLevel = UnitLevel('player')

  if cLevel < 60 then
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

function pfQuest_TWOW_GetQuestRewardById(qId, qTitle, qLevel)
  return GetQuestReward(qId, qTitle, qLevel)
end
