class GauntletWinRate {
    static function main() {
        var winRate:Float = 0.50;
        var iterations:Int = 10000;
        
        var gauntlets = 0;
        var packs = 0;
        for(i in 0...iterations)
        {
            var result = simulateGauntlets(winRate);
            gauntlets += result.gauntlets;
            packs += result.packs;
        }
            
        var avgGauntlets = gauntlets/iterations;
        var avgPacks = packs/iterations;
    	trace("----------------");
    	trace(iterations + " iterations @ win rate " + (Std.int(winRate*100))+"%" + " = " + Math.round(avgGauntlets) + " gauntlets before running out of tickets, average winnings " + Math.round(avgPacks));
     }
        
    static function simulateGauntlets(winRate:Float):GauntletResult
    {
        var result = {
            wins:0,
            losses:0,
            tickets:5,
            packs:0,
            gauntlets:0
        }
        
		var gauntlets = 0;
        while(result.tickets > 0){
            var oldTickets = result.tickets;
            var oldPacks = result.packs;
            result.wins = 0;
            result.losses = 0;
            simulateGauntlet(winRate, result);
            result.gauntlets++;
        }
            
        //trace("Played " + result.gauntlets + " gauntlets before running out of tickets. Won " + result.packs + " packs");
        return result;
    }
            
    static function simulateGauntlet(winRate:Float, result:GauntletResult):GauntletResult
    {
        var games = 5;
        result.tickets--;
        while(games > 0)
        {
            var win = playGame(winRate);
            if(win){
                result.wins++;
            }else{
                result.losses++;
            }
            games--;
            if(result.losses >= 2) games = 0;
            if(result.wins == 3) result.tickets++;
            if(result.wins == 4) result.packs++;
            if(result.wins == 5) result.packs++;
        }
        return result;
    }
    
    static function playGame(winRate:Float):Bool
    {
        if(Math.random() < winRate) return true;
        return false;
    }
}

typedef GauntletResult =
{
    wins:Int,
    losses:Int,
    tickets:Int,
    packs:Int,
    gauntlets:Int
};