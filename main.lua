--[[
@TheAlmightyForehead
March 18th, 2024
This service handles currencies
]]

-- SERVICES --
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- KNIT --
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal)

-- DATASTORES --
local DataStore = DataStoreService:GetDataStore("CURRENCY_SERVICE_DATA")

local Currency = Knit.CreateService {
	Name = "CurrencyService",
	
	AddedCurrency = Signal.new(),
	RemovedCurrency = Signal.new(),
	CurrencyChanged = Signal.new(),
	DataChanged = Signal.new(),
	DataLoaded = Signal.new(),
	
	PlayerData = {},
	
	Client = {
		AddedCurrency = Knit.CreateSignal(),
		RemovedCurrency = Knit.CreateSignal(),
		CurrencyChanged = Knit.CreateSignal(),
		DataChanged = Knit.CreateSignal(),
		DataLoaded = Knit.CreateSignal()
	}
}

function Currency:CreateCurrency(player : Player, currencyName : string, startAmount : number?)
	if not self.PlayerData[player][currencyName] then
		self.PlayerData[player][currencyName] = {}

		if startAmount then
			self.PlayerData[player][currencyName] = startAmount

			self.AddedCurrency:Fire(player, currencyName, startAmount)
			self.CurrencyChanged:Fire(player, currencyName, self.PlayerData[player][currencyName])
			self.Client.AddedCurrency:Fire(player, currencyName, startAmount)
			self.Client.CurrencyChanged:Fire(player, currencyName, self.PlayerData[player][currencyName])
		end

		self.DataChanged:Fire(player, self.PlayerData[player])
		self.Client.DataChanged:Fire(player, self.PlayerData[player])
	end

	return self.PlayerData[player]
end

function Currency:DestroyCurrency(player : Player, currencyName : string)
	self.PlayerData[player][currencyName] = nil
	
	self.DataChanged:Fire(player, self.PlayerData[player])
	self.Client.DataChanged:Fire(player, self.PlayerData[player])

	return self.PlayerData[player]
end

function Currency:GetData(player : Player)
	return self.PlayerData[player]
end

function Currency:GetAmount(player : Player, currencyName : string) : number
	return self.PlayerData[player][currencyName] or 0
end

function Currency:CanPlayerAfford(player : Player, currencyName : string, amountToCheck : number) : boolean
	if self.PlayerData[player][currencyName] then
		return self.PlayerData[player][currencyName] >= amountToCheck
	else
		return false
	end
end

function Currency:SetAmount(player : Player, currencyName : string, amountToSet : number)
	self.PlayerData[player][currencyName] = amountToSet
	self.CurrencyChanged:Fire(player, currencyName, self.PlayerData[player][currencyName])
end

function Currency:Add(player : Player, currencyName : string, amountToAdd : number) : number
	if not self.PlayerData[player][currencyName] then
		self.PlayerData[player][currencyName] = 0
	end
	
	self.PlayerData[player][currencyName] += amountToAdd
	
	self.AddedCurrency:Fire(player, currencyName, amountToAdd)
	self.CurrencyChanged:Fire(player, currencyName, self.PlayerData[player][currencyName])
	self.DataChanged:Fire(player, self.PlayerData[player])
	self.Client.AddedCurrency:Fire(player, currencyName, amountToAdd)
	self.Client.CurrencyChanged:Fire(player, currencyName, self.PlayerData[player][currencyName])
	self.Client.DataChanged:Fire(player, self.PlayerData[player])
	
	return self.PlayerData[player][currencyName] or 0
end

function Currency:Subtract(player : Player, currencyName : string, amountToSubtract : number) : number
	if not self.PlayerData[player][currencyName] then
		self.PlayerData[player][currencyName] = 0
	end
	
	self.PlayerData[player][currencyName] -= amountToSubtract
	
	self.RemovedCurrency:Fire(player, currencyName, amountToSubtract)
	self.CurrencyChanged:Fire(player, currencyName, self.PlayerData[player][currencyName])
	self.DataChanged:Fire(player, self.PlayerData[player])
	self.Client.RemovedCurrency:Fire(player, currencyName, amountToSubtract)
	self.Client.CurrencyChanged:Fire(player, currencyName, self.PlayerData[player][currencyName])
	self.Client.DataChanged:Fire(player, self.PlayerData[player])

	return self.PlayerData[player][currencyName] or 0
end

function Currency:LoadData(player : Player)
	local data

	local success, err = pcall(function()
		data = DataStore:GetAsync(player.UserId .. "_CURRENCY_DATA")
	end)

	if success then
		self.PlayerData[player] = data or {}

		self.DataChanged:Fire(player, self.PlayerData[player])
		self.DataLoaded:Fire(player, self.PlayerData[player])
		self.Client.DataChanged:Fire(player, self.PlayerData[player])
		self.Client.DataLoaded:Fire(player, self.PlayerData[player])

		return self.PlayerData[player]
	else
		warn(err)
		warn("Failed to load INVENTORY data for " .. player.Name .. " (" .. player.UserId .. ").")
		player:Kick("Error while retreiving INVENTORY data, please rejoin.")
	end
end

function Currency:SaveData(player : Player)
	local success, err = pcall(function()
		DataStore:SetAsync(player.UserId .. "_INVENTORY_DATA", self.PlayerData[player])
	end)

	if not success then
		warn(err)
		warn("Failed to save INVENTORY data for " .. player.Name .. "(" .. player.UserId .. ").")
	else
		return self.PlayerData[player]
	end
end

function Currency.Client:GetData(player : Player)
	return self.Server:GetData(player)
end

function Currency.Client:GetAmount(player : Player, currencyName : string) : number
	return self.Server:GetAmount(player, currencyName)
end

function Currency.Client:CanPlayerAfford(player : Player, currencyName : string, amountToCheck : number) : boolean
	return self.Server:CanPlayerAfford(player, currencyName, amountToCheck)
end

function Currency:KnitInit()
	Players.PlayerAdded:Connect(function(player)
		self:LoadData(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:SaveData(player)
		self.PlayerData[player] = nil
	end)
	
	print(script.Name .. " initialized")
end

function Currency:KnitStart()
	print(script.Name .. " started")
end

return Currency
