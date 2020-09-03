# Hockeyverse

A hockey GM simulator for the open world. The Hockeyverse allows GMs to compose a team of Non-Fungible Tokens from various blockchain ecosystems and wreak havoc on the league.

## Game Design - Initial Toughts
Game mechanics will be broken down as follows:

### League
- The league will have a leaderboard, schedule, games, player draft and a championship tournament with prizes
- Each league will have "seasons". The length of each season is TBD
- Additional leagues/tiers will be created as the user base and amount of active teams grows
- Special "fun" leagues will be considered in order to maximize value for some third-party NFTs

#### Schedule
- Games will be scheduled and take place automatically. No player engagement required
- GMs are responsible for having their rosters filled by their scheduled game time

#### Game (Match)
- Early games will be a simple stats-based simulation (no live action - just results)
- Live action games will be implemented after the beta version is completed (inspired by [Footbattle](https://footbattle.io/))
- Game stats will be saved on-chain for each team and player

#### Tournament
- Elimination-style tournaments similar to the Stanley Cup Playoffs
- Tournament winner gets a trophy and the largest prize
- Prizes are awarded to the winners of each playoff round, scaling upwards in value as the tournament advances
- Special tournaments will be hosted in addition to the standard leagues

#### Player Draft
- A draft will be hosted before each season
- Each GM in attendance can select a new player from the draft
- The selection order for each GM will be determined by their final ranking in the previous season
- Only one GM can make a selection at a time
- Selections are timed. If a GM isn't present at the draft, they miss out completely
- The highest value/potential players will only be available through the draft

### Teams (NFT)
- Teams are NFTs that contain player NFTs
- Teams have a name, city, country and fields for branding (ie. logo and colours)
- A Flow account receives a free team NFT when setting up their Hockeyverse account
- A full team of low tier Hockeyverse player NFT will be minted for the new team when it is created
- Additional team NFTs can be purchased and minted as needed

### Player (NFT)
- Hockeyverse will have procedurally generated player NFTs
- GMs can use approved third-party NFTs as players
- Third-party NFTs will require a single "hockey bag" purchase to be eligible to play

### Hockey Bags (NFT)
- Hockey bags are "loot boxes" that provide a set of gear and upgradeable player stats
- Hockey bags will provide a random player archetype for third-party players on first roll

### Gear (NFT)
- Players can own various tiers of hockey gear
- Hockey gear provides a custom ability (buff/debuff) as well as base player stats