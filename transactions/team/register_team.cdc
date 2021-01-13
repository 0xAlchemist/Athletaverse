// register_team.cdc

// Registers a team to a League

import Athletaverse from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {

        // get the public capability for the Team from storage
        let teamCapability = signer.getCapability(/public/AthletaverseTeam)

        // borrow a reference to the League from storage
        let leagueReference = signer.borrow<&Athletaverse.League>(from: /storage/AthletaverseLeague)
        ?? panic ("could not borrow league capability")

        // register the Team to the League
        leagueReference.registerTeam(teamCapability: teamCapability!)
    }
}