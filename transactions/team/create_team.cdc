// create_team.cdc
//
// This transaction creates a new Team and stores it
// in the caller's account
//

import Athletaverse from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {
        
        // create a new Team
        let newTeam <- Athletaverse.createNewTeam(teamName: "Huge Beauts")

        // save the Team to account storage
        signer.save(<-newTeam, to: /storage/AthletaverseTeam)

        // link a public capability to the Team
        signer.link<&Athletaverse.Team>(/public/AthletaverseTeam, target: /storage/AthletaverseTeam)
    }
}