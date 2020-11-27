// create_leagues.cdc
//
// This transaction creates a new League and stores it
// in the caller's account
//

import Athletaverse from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {
        
        // create a new League
        let newLeague <- Athletaverse.createNewLeague()

        // save the League to account storage
        signer.save(<-newLeague, to: /storage/AthletaverseLeague)

        // link a public capability to the League
        signer.link<&Athletaverse.League>(/public/AthletaverseLeague, target: /storage/AthletaverseLeague)
    }
}