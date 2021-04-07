// register_team.cdc

// Registers a team to a League

// TODO: Update this to add the team to a queue
// for approval by the league manager

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseLeague from 0x01cf0e2f2f715450

transaction(leagueID: UInt64, leagueOwnerAddress: Address) {
    prepare(signer: AuthAccount) {

        // get the public capability for the Team from storage
        let teamCapability = signer.getCapability(/public/AthletaverseTeam)

        // get the public account for the league owner
        let leagueOwner = getAccount(leagueOwnerAddress)

        // get the Public capability for the League Collection
        let leagueCollection = signer.getCapability
            <&AthletaverseLeague.Collection{AthletaverseLeague.CollectionPublic}>
            (AthletaverseLeague.leagueCollectionPublicPath)!
            .borrow() ?? panic("account has no League Collection")

        // borrow a reference to the League NFT
        let leagueReference = leagueCollection.borrowLeague(id: leagueID) 
            ?? panic("trying to borrow a league that does not exist")

        // register the Team to the League
        leagueReference.registerTeam(teamCapability: teamCapability)
    }
}