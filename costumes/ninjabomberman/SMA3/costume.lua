local Routine = require("routine")
local smasFunctions = require("smasFunctions")
local smasExtraSounds = require("smasExtraSounds")
local rng = require("base/rng")

local costume = {}

function costume.onInit(p)
    Sound.loadCostumeSounds()
    Routine.run(costumechange)
    registerEvent(costume,"onTickEnd")
end

function costumechange()
    Routine.wait(0)
    yoshi = require("yiYoshi/yiYoshi")

    yoshi.generalSettings.mainImage = Graphics.loadImageResolved("costumes/ninjabomberman/SMA3/main.png")
    yoshi.generalSettings.babyMarioImage = Graphics.loadImageResolved("costumes/ninjabomberman/SMA3/babyMario.png")
    yoshi.tongueSettings.image = Graphics.loadImageResolved("costumes/ninjabomberman/SMA3/tongue.png")
    yoshi.generalSettings.palettesImage = Graphics.loadImageResolved("costumes/ninjabomberman/SMA3/palettes.png")
    
    yoshi.customExitSettings.passOnMusic = SFX.open(Misc.resolveSoundFile("_OST/Super Mario Advance 3/Goal (SFX).ogg"))
    yoshi.customExitSettings.keyMusic = SFX.open(Misc.resolveSoundFile("_OST/Super Mario Advance 3/Big Boss Clear (SFX).ogg"))
    yoshi.customExitSettings.keyMusicStar = SFX.open(Misc.resolveSoundFile("_OST/Super Mario Advance 3/Big Boss Clear (SFX).ogg"))
    
    local rngjump = rng.randomInt(0,1)
    if rngjump == 0 then
        yoshi.generalSettings.jumpSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/jump"))
    elseif rngjump == 1 then
        yoshi.generalSettings.jumpSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/jump2"))
    end
    yoshi.generalSettings.hurtSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/hurt"))
    yoshi.generalSettings.deathSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/dieswithmusic"))
    yoshi.generalSettings.coinSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/coin"))
    
    Audio.sounds[5].sfx  = yoshi.generalSettings.hurtSound
    smasExtraSounds.sounds[8].sfx  = yoshi.generalSettings.deathSound
    smasExtraSounds.sounds[14].sfx = yoshi.generalSettings.coinSound
    
    yoshi.generalSettings.babyCreateBubbleSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/baby_bubbleCreated"))
    yoshi.generalSettings.babyPopBubbleSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/pop"))
    yoshi.generalSettings.babyCrySound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/babymario"))
    yoshi.generalSettings.babyRescuedSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/yoshi"))
    yoshi.generalSettings.babyKidnappedSound = SFX.open(Misc.resolveSoundFile("yiYoshi/baby_kidnapped"))
    yoshi.generalSettings.babyCarriedOffSound = SFX.open(Misc.resolveSoundFile("yiYoshi/baby_carriedOff"))

    --yoshi.generalSettings.starCounterBackImage = Graphics.loadImageResolved("yiYoshi/starCounter_back.png")
    --yoshi.generalSettings.starCounterNumbersImage = Graphics.loadImageResolved("yiYoshi/starCounter_numbers.png")

    yoshi.generalSettings.starCounterReplenishedSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/starCounter_replenished"))
    yoshi.generalSettings.starCounterSlowBeepingSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/countdownTimerNormal"))
    yoshi.generalSettings.starCounterFastBeepingSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/countdownTimerCritical"))
    yoshi.generalSettings.starCounterIncreaseSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/starget"))
    
    yoshi.introSettings.sound = SFX.open(Misc.resolveSoundFile("_OST/Super Mario Advance 3/Game Start (SFX).ogg"))
    
    yoshi.customExitSettings.keyVictorySound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/yoshi-chant2"))
    yoshi.customExitSettings.keyOpenSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/reveal"))
    yoshi.customExitSettings.keyCloseSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/keyclose"))
    
    yoshi.customExitSettings.scoreMusic = SFX.open(Misc.resolveSoundFile("_OST/Super Mario Advance 3/Score (SFX).ogg"))
    
    yoshi.flutterSettings.sound = SFX.open(Misc.resolveSoundFile("_OST/_Sound Effects/nothing.ogg"))
    yoshi.flutterSettings.soundDelay = 0
    
    yoshi.tongueSettings.startSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/tongue"))
    yoshi.tongueSettings.failedSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/hurt"))
    yoshi.tongueSettings.spitSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/spit"))
    yoshi.tongueSettings.swallowSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/swallow"))

    yoshi.tongueSettings.createEggSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/swallow"))
    yoshi.tongueSettings.startAimSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/yoshi-tongue2"))
    yoshi.tongueSettings.cycleEggsSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/swim2"))
    yoshi.tongueSettings.eggThrowSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/wah"))
    yoshi.tongueSettings.failedThrowSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/wah"))
    yoshi.tongueSettings.eggAimSound = SFX.open(Misc.resolveSoundFile("yiYoshi/aim"))
    
    yoshi.groundPoundSettings.startSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/plying"))
    yoshi.groundPoundSettings.landSound = SFX.open(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/pound-withrumble"))
    yoshi.initCharacter()
    
    ready = true
end

function costume.onTickEnd()
    local rngjump = rng.randomInt(0,1)
    if rngjump == 0 then
        smasExtraSounds.sounds[1].sfx = Audio.SfxOpen(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/jump"))
    elseif rngjump == 1 then
        smasExtraSounds.sounds[1].sfx = Audio.SfxOpen(Misc.resolveSoundFile("costumes/ninjabomberman/SMA3/SFX/jump2"))
    end
end

function costume.onCleanup(p)
    yoshi = require("yiYoshi/yiYoshi")
    yoshi.generalSettings.mainImage = Graphics.loadImageResolved("yiYoshi/main.png")
    yoshi.generalSettings.babyMarioImage = Graphics.loadImageResolved("yiYoshi/babyMario.png")
    yoshi.generalSettings.palettesImage = Graphics.loadImageResolved("yiYoshi/palettes.png")
    
    yoshi.generalSettings.jumpSound  = SFX.open(Misc.resolveSoundFile("yiYoshi/jump"))
    yoshi.generalSettings.hurtSound  = SFX.open(Misc.resolveSoundFile("yoshi-hurt"))
    yoshi.generalSettings.deathSound = SFX.open(Misc.resolveSoundFile("yiYoshi/death"))
    yoshi.generalSettings.coinSound  = SFX.open(Misc.resolveSoundFile("yiYoshi/coin"))
    
    yoshi.generalSettings.babyCreateBubbleSound = SFX.open(Misc.resolveSoundFile("yiYoshi/baby_bubbleCreated"))
    yoshi.generalSettings.babyPopBubbleSound = SFX.open(Misc.resolveSoundFile("yiYoshi/pop"))
    yoshi.generalSettings.babyCrySound = SFX.open(Misc.resolveSoundFile("yiYoshi/baby_cry"))
    yoshi.generalSettings.babyRescuedSound = SFX.open(Misc.resolveSoundFile("yoshi"))
    yoshi.generalSettings.babyKidnappedSound = SFX.open(Misc.resolveSoundFile("yiYoshi/baby_kidnapped"))
    yoshi.generalSettings.babyCarriedOffSound = SFX.open(Misc.resolveSoundFile("yiYoshi/baby_carriedOff"))

    yoshi.generalSettings.starCounterBackImage = Graphics.loadImageResolved("yiYoshi/starCounter_back.png")
    yoshi.generalSettings.starCounterNumbersImage = Graphics.loadImageResolved("yiYoshi/starCounter_numbers.png")

    yoshi.generalSettings.starCounterReplenishedSound = SFX.open(Misc.resolveSoundFile("yiYoshi/starCounter_replenished"))
    yoshi.generalSettings.starCounterSlowBeepingSound = SFX.open(Misc.resolveSoundFile("yiYoshi/starCounter_slowBeeping"))
    yoshi.generalSettings.starCounterFastBeepingSound = SFX.open(Misc.resolveSoundFile("yiYoshi/starCounter_fastBeeping"))
    yoshi.generalSettings.starCounterIncreaseSound = SFX.open(Misc.resolveSoundFile("yiYoshi/starCounter_increase"))
    
    yoshi.introSettings.sound = SFX.open(Misc.resolveSoundFile("yiYoshi/intro.ogg"))
    
    yoshi.customExitSettings.keyVictorySound = SFX.open(Misc.resolveSoundFile("yoshi"))
    yoshi.customExitSettings.keyOpenSound = SFX.open(Misc.resolveSoundFile("yiYoshi/reveal"))
    yoshi.customExitSettings.keyCloseSound = SFX.open(Misc.resolveSoundFile("yiYoshi/exit_keyClose"))

    yoshi.customExitSettings.passOnMusic = SFX.open(Misc.resolveSoundFile("yiYoshi/exit_start"))
    yoshi.customExitSettings.keyMusic = SFX.open(Misc.resolveSoundFile("yiYoshi/exit_key"))
    yoshi.customExitSettings.keyMusicStar = SFX.open(Misc.resolveSoundFile("yiYoshi/exit_key_star"))
    yoshi.customExitSettings.scoreMusic = SFX.open(Misc.resolveSoundFile("yiYoshi/exit_score"))
    
    yoshi.flutterSettings.sound = SFX.open(Misc.resolveSoundFile("yiYoshi/flutter"))
    yoshi.flutterSettings.soundDelay = 0
    
    yoshi.tongueSettings.image = Graphics.loadImageResolved("yiYoshi/tongue.png")
    yoshi.tongueSettings.startSound = SFX.open(Misc.resolveSoundFile("yiYoshi/tongue_start"))
    yoshi.tongueSettings.failedSound = SFX.open(Misc.resolveSoundFile("yiYoshi/tongue_failed"))
    yoshi.tongueSettings.spitSound = SFX.open(Misc.resolveSoundFile("birdo-spit"))
    yoshi.tongueSettings.swallowSound = SFX.open(Misc.resolveSoundFile("yoshi-swallow"))

    yoshi.tongueSettings.createEggSound = SFX.open(Misc.resolveSoundFile("yiYoshi/pop"))
    yoshi.tongueSettings.startAimSound = SFX.open(Misc.resolveSoundFile("yoshi-tongue"))
    yoshi.tongueSettings.cycleEggsSound = SFX.open(Misc.resolveSoundFile("swim"))
    yoshi.tongueSettings.eggThrowSound = SFX.open(Misc.resolveSoundFile("yiYoshi/egg_thrown"))
    yoshi.tongueSettings.failedThrowSound = SFX.open(Misc.resolveSoundFile("yiYoshi/egg_failedThrow"))
    yoshi.tongueSettings.eggAimSound = SFX.open(Misc.resolveSoundFile("yiYoshi/aim"))
    
    yoshi.groundPoundSettings.startSound = SFX.open(Misc.resolveSoundFile("yiYoshi/groundPound_start"))
    yoshi.groundPoundSettings.landSound = SFX.open(Misc.resolveSoundFile("yiYoshi/groundPound_land"))
    yoshi.flutterSettings.soundDelay = 6
    
    Defines.player_walkspeed = nil
    Defines.player_runspeed = nil

    Defines.player_grabSideEnabled = nil
    Defines.player_grabTopEnabled = nil
    Defines.player_grabShellEnabled = nil

    Sound.cleanupCostumeSounds()
    yoshi.cleanupCharacter()
end

Misc.storeLatestCostumeData(costume)

return costume