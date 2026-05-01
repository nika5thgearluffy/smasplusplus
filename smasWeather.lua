local smasWeather = {}

smasWeather.possibleWeather = {"Sunny","Rainy","Snowy"}

function smasWeather.doWeatherUpdate()
    if GameData.SMASPlusPlus.misc.weatherIsSet then -- Until connected to the internet to download weather data, it loads the weather when restarting the game to the start preboot screen, or starting it up every time
        local weatherControl = rng.randomEntry(smasWeather.possibleWeather)
        SaveData.SMASPlusPlus.misc.weatherForecast = weatherControl --Write in a better onetime day function for this
        GameData.SMASPlusPlus.misc.weatherIsSet = false
    end
end

return smasWeather