// register_team.cdc

// Registers a team to a League

// TODO: Update this to add the team to a queue
// for approval by the league manager

import Athletaverse from 0xf8d6e0586b0a20c7
import AthletaverseLeague from 0xf8d6e0586b0a20c7

transaction() {
    prepare(signer: AuthAccount) {

        // get the public capability for the Team from storage
        let teamCapability = signer.getCapability(/public/AthletaverseTeam)

        // borrow a reference to the League from storage
        let leagueReference = signer.borrow<&AthletaverseLeague.League>(from: /storage/AthletaverseLeague)
        ?? panic ("could not borrow league capability")

        // register the Team to the League
        leagueReference.registerTeam(teamCapability: teamCapability)
    }
}