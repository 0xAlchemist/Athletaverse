// create_team.cdc
//
// This transaction creates a new Team and stores it
// in the caller's account
//

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseTeam from 0x01cf0e2f2f715450

transaction(teamName: String) {
    prepare(signer: AuthAccount) {
        
        // create a new Team
        let newTeam <- Athletaverse.createNewTeam(teamName: teamName)

        // save the Team to account storage
        // TODO: Teams will be an NFT, we'll use a collection here
        signer.save(<-newTeam, to: /storage/AthletaverseTeam)

        // link a public capability to the Team
        signer.link<&AthletaverseTeam.Team>(/public/AthletaverseTeam, target: /storage/AthletaverseTeam)
    }
}