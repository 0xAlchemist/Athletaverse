// create_team.cdc
//
// This transaction creates a new Team and stores it
// in the caller's account
//

import Athletaverse from 0xf8d6e0586b0a20c7
import AthletaverseTeam from 0xf8d6e0586b0a20c7

transaction() {
    prepare(signer: AuthAccount) {
        
        // create a new Team
        let newTeam <- Athletaverse.createNewTeam(teamName: "Huge Beauts")

        // save the Team to account storage
        signer.save(<-newTeam, to: /storage/AthletaverseTeam)

        // link a public capability to the Team
        signer.link<&AthletaverseTeam.Team>(/public/AthletaverseTeam, target: /storage/AthletaverseTeam)
    }
}