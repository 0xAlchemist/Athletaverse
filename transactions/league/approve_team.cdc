// approve_register_team.cdc

// TODO: Removed this method from simplified version
// but will use this or something similar to setup
// some sort of approval process.

// Registers a team to a League

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseLeague from 0x01cf0e2f2f715450

transaction(leagueID: UInt64, teamID: UInt64) {
    prepare(signer: AuthAccount) {

        // borrow a reference to the League from storage
        let collection = signer.getCapability
            <&AthletaverseLeague.Collection{AthletaverseLeague.LeagueCollectionPublic}>
            (AthletaverseLeague.leagueCollectionPublicPath)
            .borrow() ?? panic ("could not borrow public capability for League Collection")

        let leagueRef = collection.borrowLeague(id: leagueID) ??
            panic("trying to borrow a reference to a League that does not exist")

        // register the Team to the League
        leagueRef.approveTeam(teamID)
    }
}