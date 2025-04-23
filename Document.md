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
    Title = "Insert Title", -- Fixed typo from 'Tittle'
    Description = "This is a test popup.",

    Options = {
        {
            Text = "Yes",
            Callback = function()
                print("Confirmed!")
            end
        },
        {
            Text = "No",
            Callback = function()
                print("Cancelled!")
            end
        },
    },

    Icon = "" -- Optional icon ID, e.g., "1234567890"
}

-- DO NOT DELETE!
PromptInterface.Show(Main)
```
