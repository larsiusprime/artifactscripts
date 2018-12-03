class GauntletMMR
{
	static public var skillMode = 1;
	static public var skillMismatchThreshold = 30;
	
	static function main()
	{
		var args = Sys.args();
		
		if (args.length < 5)
		{
			var str = 
			"Usage: GauntletMMR <skill> <iterations> <playercount> <skill_standard_deviation> <skill_mode>, eg: GauntletMMR 50 1000 1000 15 1" + "\n" +
			" - skill: skill percentile of the protagonist (1-100)" + "\n" +
			" - playercount: how many other players to simulate for matchmaking" + "\n" +
			" - skill_standard_deviation: standard deviation of the skill distribution (1-100)" + "\n" +
			" - skill_mode: 0 = linear, 1 = quadratic, 2 = better always wins" + "\n";
			Sys.println(str);
			Sys.exit(0);
		}
		
		var skill:Int = Std.parseInt(args[0]);
		var iterations:Int = Std.parseInt(args[1]);
		var playerCount:Int = Std.parseInt(args[2]);
		var stdDev:Int = Std.parseInt(args[3]);
		skillMode = Std.parseInt(args[4]);
		
		var player= new Player(skill);
		var players = generatePlayers(playerCount, stdDev);
		
		trace("Presimulating matchmaking pool... (" + playerCount + " players)");
		presimulateOtherPlayers(players);
		
		var minSkill = player.skill - (skillMismatchThreshold);
		var maxSkill = player.skill + (skillMismatchThreshold);
		players = cullMismatches(players, minSkill, maxSkill);
		trace(minSkill + " TO " + maxSkill);
		trace("non culled players = " + players.length);
		for(i in 0...iterations)
		{
			trace("Iteration " + (i+1) + " of " + iterations);
			player.tickets = 5;
			while (player.tickets > 0)
			{
				simulateGauntlet(player, players);
				if (player.gauntlet.gauntlets > 100)
				{
					//break;
				}
			}
		}
		
		var avgGauntlets = player.gauntlet.gauntlets/iterations;
		var avgPacks = player.packs / iterations;
		var winRate = Std.int((player.wins / player.games)*100);
		trace("-----------------");
		trace(iterations + " iterations @ skill level " + skill + " = " + Math.round(avgGauntlets) + " gauntlets before running out of tickets, average winnings " + Math.round(avgPacks) + ", flat win rate = " + winRate + "%");
	}
	
	static function cullMismatches(players:Array<Player>, min:Float, max:Float)
	{
		var arr = [];
		for (p in players){
			if (p.skill >= min && p.skill <= max){
				arr.push(p);
			}
		}
		return arr;
	}
	
	static function presimulateOtherPlayers(players:Array<Player>, rounds:Int=25)
	{
		var progress = 0.0;
		var lastp = 0;
		for (i in 0...25)
		{
			trace("...round " + i + "/" + 25);
			for (p in players)
			{ 
				p.available = true;
				if (p.gauntlet.finished) p.gauntlet.start();
			}
			
			//Make everybody play themselves a bunch just to generate gauntlet scores
			for (i in 0...players.length)
			{
				var p = players[i];
				players = Player.shuffle(players);
				if (p.available)
				{
					matchAndPlay(p, players);
				}
			}
		}
	}
	
	static function simulateGauntlet(player:Player, players:Array<Player>, print:Bool=false)
	{
		player.tickets--;
		player.gauntlet.start();
		if(print) trace("New Gauntlet! Tickets left = " + player.tickets + " player = " + player);
		var failsafe = 50;
		while (!player.gauntlet.finished)
		{
			var result = simulateRound(player, players, print);
			if (result == 0)
			{
				failsafe--;
				if (failsafe < 0)
				{
					trace("FAILSAFE");
					break;
				}
				continue;
			}
			if (player.gauntlet.finished)
			{
				break;
			}
		}
	}

	static function simulateRound(player:Player, players:Array<Player>, print:Bool=false):Int
	{
		//Shuffle the pool of opponents and mark them all as available
		players = Player.shuffle(players);
		for (p in players)
		{ 
			p.available = true;
			if (p.gauntlet.finished) p.gauntlet.start();
		}
		
		//Set up a game and play it, but don't update the opponent
		var result = matchAndPlay(player, players, false, print);
		
		return result;
	}
	
	static function matchAndPlay(player:Player, players:Array<Player>, updateOpponent:Bool=true, print:Bool=false):Int
	{
		//Find an appropriate opponent
		var opponent = matchMake(player, players, skillMismatchThreshold);
		if (opponent != null)
		{
			//Simulate a game and determine the winner
			var win = simulateGame(player, opponent, print);
			
			var str = "";
			if (print) 
			{
				str = (player + " VS " + opponent + " win = " + win);
			}
			
			//Calculate rewards
			if (win)
			{
				player.gauntlet.win();
				if(updateOpponent) opponent.gauntlet.lose();
			}
			else
			{
				player.gauntlet.lose();
				if(updateOpponent) opponent.gauntlet.win();
			}
			
			if (print)
			{
				trace(str + "--> " + player + " finished = " + player.gauntlet.finished);
			}
			
			//Pay out rewards
			if (player.gauntlet.finished)
			{
				player.packs += player.gauntlet.packs;
				player.tickets += player.gauntlet.tickets;
				player.wins += player.gauntlet.wins;
				player.games += player.gauntlet.wins + player.gauntlet.losses;
				if (print)
				{
					trace("+" + player.gauntlet.tickets + " tickets, +" + player.gauntlet.packs + " packs");
				}
			}
			if (updateOpponent && opponent.gauntlet.finished)
			{
				opponent.packs += opponent.gauntlet.packs;
				opponent.tickets += opponent.gauntlet.tickets;
			}
			
			if (win) return 1;
			if (!win) return -1;
		}
		return 0;
	}
	
	static function matchMake(player:Player, players:Array<Player>, mismatchThreshold:Float = 50):Player
	{
		for (i in 0...players.length)
		{
			var opponent = players[i];
			if (opponent == player) continue;
			
			//Opponent must not be facing someone else already
			if (opponent.available)
			{
				//Opponent 
				if (opponent.gauntlet.finished == false)
				{
					if (opponent.gauntlet.wins == player.gauntlet.wins && opponent.gauntlet.losses == player.gauntlet.losses)
					{
						var skillDelta = Math.abs(player.skill - opponent.skill);
						if (skillDelta <= mismatchThreshold)
						{
							return opponent;
						}
						else
						{
							//trace("skill mismatch, toss!");
						}
					}
					else
					{
						//trace("gauntlet win/loss mismatch, toss! me = " + player.gauntlet.wins + "/" + player.gauntlet.losses + " VS " + opponent.gauntlet.wins + "/" + opponent.gauntlet.losses);
					}
				}
				else
				{
					//trace("gauntlet finished, toss!");
				}
			}
		}
		return null;
	}
	
	static function winChance(a:Player, b:Player):Float
	{
		var aSkill = a.skill + a.gauntlet.deckStrength;
		var bSkill = b.skill + b.gauntlet.deckStrength;
		var delta = aSkill - bSkill;
		var sign = delta < 0 ? -1 : 1;
		var chanceA = 
		switch(skillMode)
		{
			default: 0.5 + (delta) / 2;
			case 1: 0.5 + ((Math.pow(Math.abs(delta), 0.5)) * sign) / 2;
			case 2: 0.5 + ((Math.pow(Math.abs(delta), 0.0)) * sign) / 2;
		}
		return chanceA;
	}
	
	static function simulateGame(a:Player, b:Player, print:Bool=false):Bool
	{
		var chanceA = winChance(a, b);
		
		var roll = Math.random();
		
		if (roll < chanceA)
		{
			return true;
		}
		return false;
	}
	
	static function generatePlayers(count:Int, stdDev:Int):Array<Player>
	{
		var players = [];
		
		//Generate a normal distribution of player skill centered on 50%, with a standard deviation of 15%
		var max:Int = 100;
		var avg:Int = 50;
		
		for (i in 0...count)
		{
			var skill = Std.int(Util.clamp(1, 100, Util.fNormal(avg, stdDev)));
			var p = new Player(skill);
			players.push(p);
		}
		
		return players;
	}
	
	static function testRand()
	{
		var nums = 500000;
		var max = 100;
		var mean = 50;
		var stdDev = 10;
		
		var values = [
			for (i in 0...nums){
				Std.int(
					Util.clamp(
						0, max, (Util.fNormal(mean, stdDev))
					)
				);
			}
		];
		
		var totalScale = 0;
		var map = new Map<Int,Int>();
		for (i in 0...values.length)
		{
			var value = values[i];
			var val = map.exists(value) ? map.get(value) : 0;
			map.set(value, val + 1);
			totalScale += value;
		}
		var chartScale = Math.sqrt(totalScale)/5;
		
		var bucketSize:Int = Std.int(max / 20);
		var counter = 0;
		var bucket = 0.0;
		for (i in 0...max)
		{
			var val = map.exists(i) ? map.get(i) : 0;
			var val2 = val;
			var val = Std.int(val/chartScale);
			bucket += val;
			if (counter >= bucketSize)
			{
				counter = 0;
				var str = StringTools.lpad(Std.string(i), " ", 3) + " : ";
				str += StringTools.lpad(Std.string(val2), " ", 6) + "  ";
				for (j in 0...val){
					str += "*";
				}
				if (val == 0 && val2 > 0)
				{
					str += ".";
				}
				trace(str);
			}
			counter++;
		}
	}
}

class Player
{
	/**
	 * A player's "true" inherent skill level, used to simulate actual wins/losses directly.
	 * A simulated proxy for actual inherent human skill that is not directly measurable
	 */
	public var skill:Float;
	public var gauntlet:Gauntlet;
	public var tickets:Int;
	public var packs:Int;
	public var available:Bool;
	public var wins:Int;
	public var games:Int;
	
	public function new(Skill:Float)
	{
		skill = Skill;
		tickets = 5;
		packs = 0;
		wins = 0;
		games = 0;
		gauntlet = new Gauntlet();
		available = true;
	}
	
	public function toString():String
	{
		return "{"+skill+"|"+gauntlet.wins+"/"+gauntlet.losses+"}";
	}
	
	public static function shuffle(arr:Array<Player>):Array<Player>
	{
		for (i in 0...arr.length-1)
		{
			var j = Util.iRandom(i, arr.length - 1);
			var temp = arr[j];
			arr[j] = arr[i];
			arr[i] = temp;
		}
		return arr;
	}
}

class Gauntlet
{
	public var finished:Bool;
	public var tickets:Int;
	public var packs:Int;
	public var wins:Int;
	public var losses:Int;
	public var gauntlets:Int;
	public var deckStrength:Float;
	public var infinites:Int;
	
	public function new()
	{
		wins = 0;
		losses = 0;
		gauntlets = 0;
		finished = false;
		tickets = 0;
		packs = 0;
		deckStrength = 0;
	}
	
	public function start()
	{
		gauntlets++;
		wins = 0;
		losses = 0;
		finished = false;
		tickets = 0;
		packs = 0;
		deckStrength = Util.fRandom(-.3, .3);
	}
	
	public function win()
	{
		wins++;
		if (wins >= 5) wins = 5;
		switch(wins)
		{
			case 5:
				finished = true;
				packs = 2;
				tickets = 1;
			case 4:
				packs = 1;
				tickets = 1;
			case 3:
				packs = 0;
				tickets = 1;
			default:
				packs = 0;
				tickets = 0;
		}
	}
	
	public function lose()
	{
		losses++;
		if (losses >= 2)
		{
			losses = 2;
			finished = true;
			switch(wins)
			{
				case 5:
					packs = 2;
					tickets = 1;
				case 4:
					packs = 1;
					tickets = 1;
				case 3:
					packs = 0;
					tickets = 1;
				default:
					packs = 0;
					tickets = 0;
			}
		}
	}
}

class Util
{
	static var _hasFloatNormalSpare:Bool = false;
	static var _floatNormalRand1:Float = 0;
	static var _floatNormalRand2:Float = 0;
	static var _twoPI:Float = 3.1415926535 * 2;
	static var _floatNormalRho:Float = 0;
	static var internalSeed:Float = 0;
	
	static inline var MODULUS:Int = 0x7FFFFFFF;
	static inline var MULTIPLIER:Float = 48271.0;

	public static function lerp(a:Float, b:Float, amount:Float):Float
	{
		return (a * (1-amount)) + (b * (amount));
	}
	
	public static function clamp(min:Float, max:Float, value:Float):Float
	{
		if (value < min) return min;
		if (value > max) return max;
		return value;
	}
	
	public static function iRandom(low:Int, high:Int):Int
	{
		var diff = (high-low)+1;
		var val = Std.int(Math.random() * diff) + low;
		return val;
	}
	
	public static function fRandom(low:Float, high:Float):Float
	{
		var diff = (high-low);
		var val = (Math.random() * diff) + low;
		return val;
	}
	
	public static function fNormal(Mean:Float = 0, StdDev:Float = 1):Float
	{
		if (_hasFloatNormalSpare)
		{
			_hasFloatNormalSpare = false;
			var scale:Float = StdDev * _floatNormalRho;
			return Mean + scale * _floatNormalRand2;
		}
		
		_hasFloatNormalSpare = true;
		
		var theta:Float = _twoPI * (generate() / MODULUS);
		_floatNormalRho = Math.sqrt( -2 * Math.log(1 - (generate() / MODULUS)));
		var scale:Float = StdDev * _floatNormalRho;
		
		_floatNormalRand1 = Math.cos(theta);
		_floatNormalRand2 = Math.sin(theta);
		
		return Mean + scale * _floatNormalRand1;
	}
	
	private static inline function generate():Float
	{
		if (internalSeed == 0) internalSeed = Math.random();
		return internalSeed = (internalSeed * MULTIPLIER) % MODULUS;
	}
}