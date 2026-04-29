local Script = {
    [9338091695] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/ReignPiece",
    [9186719164] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/SailorPiece",
    [9917246399] = "https://raw.githubusercontent.com/canhongson/CanHongSon/refs/heads/main/PiratePiece",
}

local url = Script[game.GameId]

if url then
    loadstring(game:HttpGet(url))()
end
