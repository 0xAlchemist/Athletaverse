import AthletaverseLeague from "./AthletaverseLeague.cdc"
import AthletaverseTeam from "./AthletaverseTeam.cdc"

// The main Athletaverse contract
//
// This smart contract manages global state for the Athletaverse
//
// TODO: Explain sports and league creation once prototyped
// 
// TODO: Add Collections for Team resource - are they NFTs or just similar resources?
pub contract Athletaverse {

    pub var totalTeams: UInt64

    // requestLeagueMinter sets up a capability receiver for the caller
    // that awaits approval from the LeagueSuperAdmin
    //
    // once approved, the caller can create new League
    pub fun requestLeagueMinter(_ signer: AuthAccount) {
        AthletaverseLeague.requestLeagueMintingCapability(signer)
    }

    // TODO: build a create team wrapper method...

    init() {
        self.totalTeams = 0 as UInt64
    }
}
