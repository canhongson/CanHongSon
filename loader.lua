local Scripts = {
    [9338091695] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/ReignPiece",
    [9186719164] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/SailorPiece",
}

local url = Scripts[game.GameId]

if url then
    loadstring(game:HttpGet(url))()
end
