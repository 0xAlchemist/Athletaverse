// request_register_team.cdc

// Registers a team to a League

import Athletaverse from 0xf8d6e0586b0a20c7
import AthletaverseLeague from 0xf8d6e0586b0a20c7

transaction(teamID: UInt64) {
    prepare(signer: AuthAccount) {

        // get the public capability for the Team from storage
        let teamCapability = signer.getCapability(/public/AthletaverseTeam)

        // borrow a reference to the League from storage
        let leagueReference = signer.borrow<&AthletaverseLeague.League>(from: /storage/AthletaverseLeague)
        ?? panic ("could not borrow league capability")

        // register the Team to the League
        leagueReference.removeTeam(ID: teamID)
    }
}