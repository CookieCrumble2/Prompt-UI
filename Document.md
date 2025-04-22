# Prompt UI 
Made By Sirius, forked by CookieCrumble
This documentation is for the stable release of Prompt UI.

## Initializing the UI
```lua
local PromptInterface = loadstring(game:HttpGet("https://raw.githubusercontent.com/CookieCrumble2/Prompt-UI/refs/heads/main/load.lua"))()
```



## Editing the UI
```lua
local Main = {
    Title = "Insert Tittle",
    Description = "Description",
    Options = {
        {Text = "Yes", Callback = function() print("confirmed") end},
        {Text = "No", Callback = function() print("Cancelled") end},
    };
    Icon = "1234567890" -- optional
}

PromptUI.Show(Main)
)
```
