// request_register_team.cdc

// Removes a team from a League

// TODO: Only the team owner and league manager should
// have this capability

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseLeague from 0x01cf0e2f2f715450

transaction(leagueID: UInt64, teamID: UInt64) {
    prepare(signer: AuthAccount) {

        // get the public capability for the Team from storage
        let collection = signer.getCapability
            <&AthletaverseLeague.Collection{AthletaverseLeague.CollectionManager}>
            (AthletaverseLeague.leagueCollectionManagerPrivatePath)
            .borrow() ?? panic("could not borrow CollectionManager capability")

        let league = collection.borrowManager(id: leagueID) ?? panic("League does not exist")

        // register the Team to the League
        league.removeTeam(teamID)
    }
}