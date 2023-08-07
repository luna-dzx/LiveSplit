state("What Lies Between"){}

startup
{
	vars.Log = (Action<object>)(output => print("[What Lies Between] " + output));

	if (!File.Exists(@"Components\asl-help"))
	{
		print("No asl-help detected, downloading to Components folder");
		vars.DownloadUnityHelperFunc = (Func<int>)(() =>
		{
			using (var client = new System.Net.WebClient())
			{
				client.DownloadFile("https://github.com/just-ero/asl-help/raw/main/lib/asl-help", @"Components\asl-help");
			}
			return 1;
		});
		vars.DownloadUnityHelperFunc();
		print("Downloaded asl-help");
	}

	Assembly.Load(File.ReadAllBytes(@"Components\asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "What Lies Between";
	vars.Helper.LoadSceneManager = true;

	// Start of Settings

	settings.Add("splitResults", true, "Split on every results screen");
	settings.Add("resetOnDelete", true, "Reset timer when you delete the same file you just played on");




	vars.Helper.AlertGameTime();

	vars.GameTime = 0f;
	vars.totalPauseRTA = new TimeSpan(0);
	vars.previousRTA = new TimeSpan(0);

    vars.oldTimer = 0f;
    vars.currentTimer = 0f;

    vars.oldScene = 0;
    vars.currentScene = 0;

    vars.mainMenu = false;


    //nonLevels = new int[] {0,2,6,13,16,18,23,25,27,28};
    vars.isCutscene = new bool[29];
    vars.isCutscene[0] = true;
    vars.isCutscene[2] = true;
    vars.isCutscene[6] = true;
    vars.isCutscene[13] = true;
    vars.isCutscene[16] = true;
    vars.isCutscene[18] = true;
    vars.isCutscene[23] = true;
    vars.isCutscene[25] = true;
    vars.isCutscene[27] = true;
    vars.isCutscene[28] = true;


    vars.resetTimer = 0f;
    
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		vars.Helper["Timer"] = mono.Make<float>("Timer", "Frames");

		return true;
	});

	vars.Helper.Load();
}

update
{
	if (!vars.Helper.Loaded)
		return false;

    vars.Helper.Update();

    vars.currentScene = vars.Helper.Scenes.Active.Index;
    vars.currentTimer = vars.Helper["Timer"].Current;

    float deltaTime = vars.currentTimer - vars.oldTimer;
    vars.GameTime += deltaTime;

    vars.oldTimer = vars.currentTimer;

    if (vars.currentScene == 0 && !vars.mainMenu) {
        vars.resetTimer += 0.05f;
        if (vars.resetTimer > 1f)
        {
            vars.mainMenu = true;
        }
    }
    else
    {
        vars.resetTimer = 0f;
    }
}

gameTime
{
	return TimeSpan.FromSeconds(vars.GameTime);
}

isLoading
{
    return true;
}

split
{
    bool split = false;
    vars.mainMenu = false;
    if (vars.currentScene != vars.oldScene && vars.oldScene != 0 && vars.currentScene != 0 && !vars.isCutscene[vars.currentScene])
    {
        split = true;
        vars.oldScene = vars.currentScene;
    }


    return split;
    
}

start
{
    bool split = false;
    if (vars.currentScene==1 && vars.oldScene==0) {
        split = true;
        vars.resetTimer = 0f;
        vars.mainMenu = false;
    }
    vars.oldScene = vars.currentScene;
    return split;
}

reset
{
    if (vars.mainMenu)
    {
        vars.mainMenu = false;
        vars.resetTimer = 0f;
        return true;
    }
    return false;   
}