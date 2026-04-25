local Levul = {}

function Levul.markComplete(incrementCount, isOptional, addToTable)
    if (GameData.rushModeActive == nil or not GameData.rushModeActive) then
        if isOptional then
            if not table.icontains(SaveData.SMASPlusPlus.levels.complete.optional,Level.filename()) then
                if addToTable then
                    table.insert(SaveData.SMASPlusPlus.levels.complete.optional,Level.filename())
                end
                if incrementCount then
                    SaveData.SMASPlusPlus.levels.starCount = SaveData.SMASPlusPlus.levels.starCount + 1
                else
                    SaveData.SMASPlusPlus.levels.starCount = SaveData.SMASPlusPlus.levels.starCount
                end
            elseif table.icontains(SaveData.SMASPlusPlus.levels.complete.optional,Level.filename()) then
                SaveData.SMASPlusPlus.levels.starCount = SaveData.SMASPlusPlus.levels.starCount
            end
        else
            if not table.icontains(SaveData.SMASPlusPlus.levels.complete.normal,Level.filename()) then
                if addToTable then
                    table.insert(SaveData.SMASPlusPlus.levels.complete.normal,Level.filename())
                end
                if incrementCount then
                    SaveData.SMASPlusPlus.levels.starCount = SaveData.SMASPlusPlus.levels.starCount + 1
                else
                    SaveData.SMASPlusPlus.levels.starCount = SaveData.SMASPlusPlus.levels.starCount
                end
            elseif table.icontains(SaveData.SMASPlusPlus.levels.complete.normal,Level.filename()) then
                SaveData.SMASPlusPlus.levels.starCount = SaveData.SMASPlusPlus.levels.starCount
            end
        end
    end
end

return Levul