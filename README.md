# Prompt UI 
Made By Sirius, forked by CookieCrumble
This documentation is for the stable release of Prompt UI.

[![IMG-9179.jpg](https://i.postimg.cc/3xBKZD57/IMG-9179.jpg)](https://postimg.cc/sMMdjxg0)
## Initializing the UI
```lua
local PromptInterface = loadstring(game:HttpGet("[https://raw.githubusercontent.com/CookieCrumble2/Prompt-UI/refs/heads/main/load.lua](https://raw.githubusercontent.com/CookieCrumble2/Prompt-UI/refs/heads/main/Source.lua)"))()
```



## Editing the UI
```lua
PromptInterface.create(
    "Welcome to Prompt UI", -- Title
    "This is a demo prompt using the Sirous Prompt Interface.", -- Description
    "Accept", -- Primary Button Text
    "Cancel", -- Secondary Button Text
    function(response)
        if response then
        -- Add loadstring or script
        else
        -- Add Loadstring or script
        end
    end
)
```
 ## Credits
 - Lucide Icons
   **https://lucide.dev**
- Sirius
  **https://sirius.menu**
