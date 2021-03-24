// create_leagues.cdc
//
// This transaction creates a new League and stores it
// in the caller's account
//

import Athletaverse from 0xf8d6e0586b0a20c7
import AthletaverseLeague from 0xf8d6e0586b0a20c7

transaction() {
    prepare(signer: AuthAccount) {
        
        // create a new League
        let newLeague <- Athletaverse.createNewLeague(name: "Alpha League")

        // save the League to account storage
        signer.save(<-newLeague, to: /storage/AthletaverseLeague)

        // link a public capability to the League
        signer.link<&AthletaverseLeague.League>(/public/AthletaverseLeague, target: /storage/AthletaverseLeague)
    }
}