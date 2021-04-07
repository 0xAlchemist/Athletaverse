// create_leagues.cdc
//
// This transaction creates a new League and stores it
// in the caller's account
//

import Athletaverse from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {
        
        // create a new League
        Athletaverse.requestLeagueMinter(signer)
    }
}