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
| 25%              | 5                 | 0                 |12%           |
| 40%              | 5                 | 0                 |33%           |
| 46%              | 6                 | 0                 |44%           |
| 50%              | 8                 | 1                 |52%           |
| 60%              | 22                | 15                |65%           |
| 62%              | 36                | 37                |70%           |
| 65%              |                   |                   |  %           |
| 70%              |                   |                   |  %           |
| 75%              |                   |                   |  %           |
| 80%              |                   |                   |  %           |
| 80.6%            |                   |                   |  %           |
| 85%              |                   |                   |  %           |
| 90%              |                   |                   |  %           |

Based on 10,000 iterations each with the following parameters:
- 1000 players in match-making pool
- Standard deviation of 15 skill points
- Quadratic algorithm for match resolution (method "1")
