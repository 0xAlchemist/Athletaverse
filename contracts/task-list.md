# Contract To-Do List

- [ ] Athlete NFT
- [ ] Gear NFT
- [ ] Venue NFT

## Athletaverse
This contract is the main entry point for the Athletaverse. It manages global state and provides methods for interacting with the smart contract and it's various assets.

- [x] Create New League (£)
- [x] Create New Team
- [ ] Mint New Athlete (£π)
- [ ] Mint New Gear (£π)
- [ ] League Admin Resource (Init Singleton)
- [ ] NFT Admin Resource (£)

## AthletaverseLeague
This contract defines the League resource.

- [x] Register Team
- [x] Remove Team
- [x] Get Team IDs
- [x] Get Team Info
- [ ] Support multiple leagues (Collection pattern -> NFT?)
- [ ] Should there be an approval queue for addTeam?
## AthletaverseTeam
This contract defines the Team resource.

- [x] Add Athlete to Team
- [x] Remove Athlete from Team
- [x] Update Team Name
- [x] Get Athlete IDs
- [ ] Support multiple teams (Collection pattern -> NFT?)
- [ ] Should there be an approval queue for addAthlete?

## AthletaverseAthlete
This contract defines the Athlete NFT.

- [ ] Uses onflow NFT interface
- [ ] Add Gear to Athlete
- [ ] Remove Gear from Athlete
- [ ] Get Gear IDs
- [ ] Get Gear Info
- [ ] Athlete Minter

## AthletaverseGear
This contract defines the Gear NFT.

- [ ] Uses onflow NFT interface
- [ ] Gear Minter


## Restricted Capabilities
Some methods will be restricted to the owners of certain admin resources:

- £ = League Admin
- π = NFT Admin