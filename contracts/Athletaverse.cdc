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

    // createNewTeam creates a new Team resource and returns it to the caller
    //
    // TODO: Pick an option:
    // - First team free, additional teams require payment
    // - All teams require payment
    // - One team per user
    pub fun createNewTeam(teamName: String): @AthletaverseTeam.Team {
        
        // set the total Teams count as the teamID
        let teamID = Athletaverse.totalTeams

        // increment the totalTeams count by one
        Athletaverse.totalTeams = Athletaverse.totalTeams + 1 as UInt64
        
        // return the new Team to the caller
        return <- AthletaverseTeam.createNewTeam(ID: teamID, name: teamName)
    }

    init() {
        self.totalTeams = 0 as UInt64
    }
}
