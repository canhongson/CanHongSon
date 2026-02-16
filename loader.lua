local Scripts = {
    [78466992256287] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/ReignPiece",
    [77747658251236] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/SailorPiece",
    [75159314259063] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/SailorPiece",
    [99684056491472] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/SailorPiece"
}

local url = Scripts[game.PlaceId]

if url then
    loadstring(game:HttpGet(url))()
end
