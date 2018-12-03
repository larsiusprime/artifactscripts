# artifactscripts
Various scripts related to Valve's game Artifact

# Basics

## Setup:
1. Install [Haxe toolkit](https://haxe.org/)
2. Install hxcpp: `haxelib install hxcpp` (optional, but recommended)

## Run a script:
```
haxe --run <FileName>.hx
```

## Compile a script:

```
haxe -main <ClassName> -cpp bin
```
(requires hxcpp)

How far can you go in Artifact expert gauntlets on skill alone? Let's find out with these monte carlo scripts.

(WIP, kinda trashy)

# Script usage

1. GauntletWinRate:
No parameters, just call it directly (edit source to change behavior)

2. GauntletMMR:
```
Usage: GauntletMMR <skill> <iterations> <playercount> <skill_standard_deviation> <skill_mode>, eg: GauntletMMR 50 1000 1000 15 1
 - skill: skill percentile of the protagonist (1-100)
 - playercount: how many other players to simulate for matchmaking
 - skill_standard_deviation: standard deviation of the skill distribution (1-100)
 - skill_mode: 0 = linear, 1 = quadratic, 2 = better always wins
```

# GauntletWinRate

A simple model that simulates how far you can go in an Artifact expert gauntlet with 5 tickets, depending on your flat winrate.

Matches are resolved simply by rolling against your flat winrate.

# GauntletMMR

A fancier model that takes matchmaking into account. Also specifically simulates draft.

Valve has gone on record that Gauntlet matchmaking does three things:

1. Sets you up with someone of an identical win/loss rate in their current gauntlet
2. Throws out "gross skill mismatches"
3. Explicitly does not try to force 50% win rate matchups

Taking them at their word, we try to to simulate that. The model presimulates a population of other players with a normal distribution of skill, then
makes them play a bunch of rounds against each other to give them each gauntlet win rates. These players are then frozen, and used as matchmaking fodder
for the simulated protagonist.

Matches are resolved by comparing player skill and using one of three algorithms (linear, quadratic, and "pure" (higher skill always wins)). Additionally,
at the start of each player's current gauntlet they get a random -0.3 to +0.3 modifier to their skill to simulate deck power from draft. The way this works
out with the match resolver algorithm is those with already high base skill are perturbed less by this, and those with low base skill benefit the most (an 
expert with a garbage deck has still got a great chance against a moron with a stupendous deck, but it's not longer a slam dunk).

The model's big assumptions are:
- Skill is normally distributed and centered on 0.5
- Skill has a certain standard deviation (user supplied)
- "Gross mismatch" in player skill is 30 percentile points or so

Feel free to play around.
