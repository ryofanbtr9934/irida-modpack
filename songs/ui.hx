import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.backend.scripting.Script;
import flixel.util.FlxStringUtil;
import StringTools;

PauseSubState.script = "data/scripts/pause";
GameOverSubstate.script = "data/scripts/gameover-shucks";

playCutscenes = FlxG.save.data.iridaCutscenes;

public var camNotes:HudCamera = new HudCamera();

public var iridaBar:FunkinSprite = new FunkinSprite();
public var timeTitle:FunkinText;
public var timeTxt:FunkinText;

public var flasher:FunkinSprite = new FunkinSprite().makeSolid(FlxG.width, FlxG.height);

var whydoihavetodothis = {healthyeah: 1}

var txts:Array<FunkinText> = [];
var barPath:String;

function postCreate() {
    FlxG.cameras.insert(camNotes, 1, false).bgColor = FlxColor.TRANSPARENT;
    camNotes.downscroll = Options.downscroll;
    strumLines.members[0].camera = strumLines.members[1].camera = camNotes;
    // coolflash
    add(flasher).scrollFactor.set();
    flasher.zoomFactor = flasher.alpha = 0;    

    // icons
    iconP1.scrollFactor.set(1, 1);
    iconP2.scrollFactor.set(1, 1);
    updateIconPositions = () -> {
        iconP1.x = 975;
        iconP2.x = 150;
        iconP1.health = healthBar.percent / 100;
		iconP2.health = 1 - (healthBar.percent / 100);
    };
    iconP1.bump = iconP2.bump = () -> {
        iconP1.scale.set(1.2, 1.2);
        iconP2.scale.set(1.2, 1.2);
    };
    iconP1.updateBump = iconP2.updateBump = () -> {
        iconP1.scale.set(CoolUtil.fpsLerp(iconP1.scale.x, 1, 0.11), CoolUtil.fpsLerp(iconP1.scale.y, 1, 0.11));
        iconP2.scale.set(CoolUtil.fpsLerp(iconP2.scale.x, 1, 0.11), CoolUtil.fpsLerp(iconP2.scale.y, 1, 0.11));
    };
    // score texts    // thsi is so ugly im sorry they have me in the irida sweatshop rn help me
    for (a in txts = FlxG.save.data.iridaTimer ? [scoreTxt, accuracyTxt, missesTxt, timeTxt = new FunkinText(0, 0, FlxG.width, FlxStringUtil.formatTime(inst.length / 1000, false), 60, false), timeTitle = new FunkinText(0, 0, FlxG.width, FlxStringUtil.formatTime(inst.length / 1000, false), 40, false)] : [scoreTxt, accuracyTxt, missesTxt]) {
        a.setFormat(Paths.font("SuperMario256.ttf"), a == timeTxt || a == timeTitle ? 70 : 20, 0xFF8B0000, a == timeTxt || a == timeTitle ? "center" : a.alignment, FlxTextBorderStyle.OUTLINE);
        a.antialiasing = Options.antialiasing;
        if (a != timeTxt && a != timeTitle) a.fieldWidth *= 1.2;
        a.y = a == timeTxt || a == timeTitle ? 77 : 668;
        a.screenCenter(FlxAxes.X);
        a.scrollFactor.set(1, 1);
    }
    accuracyTxt.removeFormat(accFormat);
    if (FlxG.save.data.iridaTimer) {
        timeTitle.scrollFactor.set();
        timeTxt.scrollFactor.set();
        timeTxt.x = timeTitle.x = 0;
        insert(0, timeTxt).camera = timeTitle.camera = camNotes;
        insert(0, timeTitle).scale.set(1.05, 1.05);
    }

    // healthbar
    setIridaBar("default");

    remove(healthBarBG);
    insert(members.indexOf(healthBar) + 1, iridaBar).camera = camHUD;
    iridaBar.setPosition(FlxG.width / 2 - 1010 / 2, healthBar.y - 75);
    iridaBar.antialiasing = Options.antialiasing;

    healthBar.scale.set(1.25, 1.25);
    healthBar.setParent(whydoihavetodothis, "healthyeah");
    healthBar.numDivisions *= 1000;
    healthBar.scrollFactor.set(1, 1);

    scripts.call("postPostCreate");
}

function update() {
    camNotes.zoomMultiplier = camHUD.zoomMultiplier;
    camNotes.zoom = camHUD.zoom;
}

function postUpdate() {
    whydoihavetodothis.healthyeah = lerp(whydoihavetodothis.healthyeah, health, 0.11);

    if (Conductor.songPosition >= 0 && timeTxt != null)
        timeTxt.text = timeTitle.text = FlxStringUtil.formatTime(((SONG.meta.name.toLowerCase() == "squcks" ? Conductor.stepCrochet * 400 : inst.length) - Conductor.songPosition) / 1000, false);

    if(flasher.angle != -camGame.angle && flasher.alpha != 0) flasher.angle = -camGame.angle;
}

function onPostStrumCreation(e)
    e.strum.scrollFactor.set(1, 1);

function onNoteHit(e) {
    if (e.note.isSustainNote) e.healthGain = 0;
    e.ratingSuffix = switch (barPath.split("game/bars/")[1]) {
        case "shadow": "-shadow";
        default: e.ratingSuffix;
    }
}

// CUSTOM FUNCTIONS

public function setIridaBar(_:String) {
    if (!Assets.exists(Paths.image("game/bars/" + _)) || barPath == "game/bars/" + _)
        return;

    barPath = "game/bars/" + _;

    if (Options.downscroll) {
        if (Assets.exists(barPath + "-downscroll")) barPath += "-downscroll";
        iridaBar.flipY = !StringTools.endsWith(barPath, "-downscroll");
    }

    switch (_) { // extra shit that is linked to healthbars, makes it easier ig
        case "shadow":
            for (a in txts) {
                a.color = FlxColor.BLACK;
                a.setBorderStyle(a.borderStyle, FlxColor.WHITE, 48 / a.size);
            }
            timeTitle?.color = FlxColor.WHITE;
        default:
            for (a in txts) {
                a.color = 0xFF8B0000;
                a.setBorderStyle(a.borderStyle, FlxColor.BLACK, 48 / a.size);
            }
            timeTitle?.color = FlxColor.BLACK;
    }

    iridaBar.loadGraphic(Paths.image(barPath));
}

public static function setStrumSkin(_:String, strums:Array<Int>) { // setStrumSkin("noteskin", [0, 1, 2]); to set all 3 strusm to noteskin
    if (!Assets.exists(Paths.image("game/notes/" + _)) || !Assets.exists(Paths.file("images/game/notes/" + _ + ".xml")))
        return;

    var idk:Array<String> = ["left", "down", "up", "right"];
    for (z in strums)
        for (a in strumLines.members[z].members) {
            a.frames = Paths.getSparrowAtlas("game/notes/" + _);
            a.animation.addByPrefix("static", "arrow" + idk[a.ID].toUpperCase());
            a.animation.addByPrefix("pressed", idk[a.ID] + " press", 24, false);
            a.animation.addByPrefix("confirm", idk[a.ID] + " confirm", 24, false);
            a.animation.play('static');
            a.updateHitbox();
        }
}

public static function coolFlash(color:FlxColor, lengthInStep:Int, power:Float) {
    if (Options.flashingMenu) {
        FlxTween.cancelTweensOf(flasher);
        flasher.color = color;
        flasher.alpha = power;
        FlxTween.tween(flasher, {alpha: 0}, (Conductor.stepCrochet / 1000) * lengthInStep);
    }
}
