# Flat win rate 
Source: GauntletWinRate.hx
Can be considered either constructed or draft

| Win rate | Average gauntlets | Average packs won |Infinite rate|
|----------|-------------------|-------------------|-------------|
| 25%      | 6                 | 0                 |0%           |
| 40%      | 7                 | 1                 |0%           |
| 46%      | 9                 | 2                 |0%           |
| 50%      | 10                | 3                 |0%           |
| 60%      | 17                | 8                 |0%           |
| 62%      | 19                | 10                |0%           |
| 65%      | 23*               | 14*               |1%           |
| 70%      | 37*               | 28*               |5%           |
| 75%      | 61*               | 58*               |18%          |
| 80%      | 104*              | 119*              |46%          |
| 80.6%    | 109*              | 128*              |50%          |
| 85%      | 160*              | 234*              |78%          |
| 90%      | 234*              | 368*              |95%          |

Based on 100,000 iterations each

*Script triggered an infinite loop failsafe cutoff at least once, supressing the eventual value this could have been

# Skill percentile
Source: GauntletMMR.hx
Specifically models draft, takes matchmaking ramp into account

| Skill percentile | Average gauntlets | Average packs won | Flat winrate |
|------------------|-------------------|-------------------|--------------|
| 25th             | 5                 | 0                 |12%           |
| 4th              | 5                 | 0                 |33%           |
| 46th             | 6                 | 0                 |44%           |
| 50th             | 8                 | 1                 |52%           |
| 53rd             | 11                | 2                 |54%           |
| 55th             | 12                | 4                 |58%           |
| 57th             | 17                | 7                 |60%           |
| 60th             | 22                | 15                |65%           |
| 62nd             | 36                | 37                |70%           |
| 65th             | 44                | 52                |73%           |
| 70th*            | 196               | 353               |83%           |
| 75th*            |                   |                   |  %           |

Based on 10,000 iterations each with the following parameters:
- 1000 players in match-making pool
- Standard deviation of 15 skill points
- Quadratic algorithm for match resolution (method "1")

\*Based on 1,000 iterations because the script was taking super long at this high a skill percentile.
