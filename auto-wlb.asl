state("What Lies Between") {}

startup
{
    // if (!File.Exists("Components/asl-help"))
    // {
    //     throw new InvalidOperationException("No asl-help detected");
    // }

    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "What Lies Between";
    vars.Helper.LoadSceneManager = true;

    // Start of Settings

    settings.Add("splitResults", true, "Split on every results screen");
    settings.Add("resetOnDelete", true, "Reset timer when you delete the same file you just played on");

    vars.stopwatch = new Stopwatch();
    vars.cutsceneScenes = new HashSet<int> { 0, 2, 6, 13, 16, 18, 23, 25, 27, 28 };

    vars.Helper.AlertGameTime();
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["Timer"] = mono.Make<float>("Timer", "Frames");

        return true;
    });
}

update
{
    current.Scene = vars.Helper.Scenes.Active.Index;
}

gameTime
{
    return TimeSpan.FromSeconds(current.Timer);
}

isLoading
{
    return true;
}

split
{
    return old.Scene != current.Scene && old.Scene != 0 && current.Scene != 0 && !vars.cutsceneScenes.Contains(current.Scene);
}

start
{
    return old.Scene == 0 && current.Scene == 1;
}

reset
{
    if (old.Scene != 0 && current.Scene == 0)
    {
        vars.stopwatch.Restart();
    }

    if (vars.stopwatch.Elapsed.TotalSeconds >= 1)
    {
        vars.stopwatch.Reset();
        return true;
    }
}
