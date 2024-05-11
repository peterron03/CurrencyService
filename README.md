# CurrencyService
A Currency system for Roblox, built using the Knit framework.

## What is CurrencyService?
To put it simply, CurrencyService is a server-sided table of data that you can add to, remove from, or get from. It allows for multiple currencies all in one place and easy organization to deal with. CurrencyService is by no means a top-tier must-have, but it's something I made for myself and decided to share with the world for anyone that might find it interesting or useful.

## What is Knit?
As stated in the very short description of InventoryService, Knit is used as a dependency. If you're unfamiliar with Knit, I highly suggest watching [this](https://www.youtube.com/watch?v=0Ty2ojfdOnA) video, which is a tutorial made by [@sleitnick](https://github.com/Sleitnick), the creator of Knit. Though CurrencyService can be used without much knowledge of Knit, it's recommended you understand Knit first.

## Examples
CurrencyService is very simple and easy to use. To start off, even though it's not required as most functions automatically create a currency if it doesn't already exist, we're going to create an inventory when the player joins a game. You don't need to do this, but it's useful for better organization and overall ease of use. And of course, we'll be using Knit as it's required for CurrencyService.
```lua
-- Get Knit, the framework used for CurrencyService:
local Knit = require(game.ReplicatedStorage.Knit)

-- Load the CurrencyService module from some folder, as well as any other modules you have:
Knit.AddServices(game.ServerScriptService.Services)

-- Start Knit:
Knit.Start():andThen(function()
	print("Knit started")
end):catch(warn)

-- Get the CurrencyService:
local CurrencyService = Knit.GetService("CurrencyService")

-- Create a Currency for a player upon joining:
game.Players.PlayerAdded:Connect(function(player)
  CurrencyService:CreateCurrency(player, "Coins", 100)
end)
```
And there you have it, we now have a Coins currency created! We also decided to give the player 100 starter coins using the 3rd parameter, which is optional.

Now that we have our currency, it's time to put it to use. For this example, we're just going to check and remove the coins if necessary when a player attempts to purchase something, using a RemoteEvent and an Inventory table. (Note: If you'd like an Inventory system as well, you can check out my [InventoryService](https://github.com/peterron03/InventoryService), which is set up a lot like CurrencyService and works well with it.)
```lua
-- RemoteEvent to buy an item:
local RemoteEvent = somewhere.RemoteEvent

-- Taking a player's coins and giving the requested item if they can afford it:
RemoteEvent.OnServerEvent:Connect(function(player, item)
  if CurrencyService:CanPlayerAfford(player, "Coins", somewhere[item].Price) then
    CurrencyService:Subtract(player, "Coins", somewhere[item].Price)
    givePlayerItem(player, item)
  end
end)
```
Now we've given the player an item and taken their coins after finding out they have enough to afford it! But, wait, we're not done yet. Now with their Coins total changed, we need to update the client so the player knows how much they have. Luckily, we have events to help us out with that.
```lua
-- In a LocalScript, assuming Knit has been set up on the client, as well:
CurrencyService.CurrencyChanged:Connect(function(currencyName, amount)
  -- update Coins anywhere needed on the client, however you have it set up
end)
```
And there we go! We've successfully set up a little shop system. And keep in mind, while `.CurrencyChanged` is being used on the client in the above example, it can also be used on the server. The only difference is the first parameter being `player`, which is the player that received the added item, followed by `currencyName` and `amount`, of course.

Overall, that's about it for some little examples. There's more to CurrencyService, though, such as client and server communication using Knit, getting amounts, and so on. For all of that, check out the documentation (if I've even done that by the time you read this) or just go through the open-sourced code if you know enough about programming.

## Documentation
Coming soon... maybe...
