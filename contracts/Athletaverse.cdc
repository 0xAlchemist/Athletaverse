import AthletaverseLeague from "./AthletaverseLeague.cdc"
import AthletaverseTeam from "./AthletaverseTeam.cdc"

// The main Athletaverse contract
//
// This smart contract manages global state for the Athletaverse
//
// TODO: Explain sports and league creation once prototyped
// 
// TODO: Add Collections for League and Team resource - are they NFTs or just similar resources?
pub contract Athletaverse {
    
    // totalLeagues represents the total number of Leagues that have been created
    access(contract) var totalLeagues: UInt64

    // totalTeams represents the total number of Teams that have been created
    access(contract) var totalTeams: UInt64
    
    // TODO: This should be 'admin only' - could make this something users need to
    // 'unlock' via purchase, or by committing their initial prize Vault to prevent
    // spam League creation
    // 
    // createNewLeague creates a new League resource and returns it to the caller
    pub fun createNewLeague(name: String, rosterSize: Int): @AthletaverseLeague.League {
        
        // set the league ID to the total number of leagues
        let ID = Athletaverse.totalLeagues

        // increment the total number of leagues by one
        Athletaverse.totalLeagues = Athletaverse.totalLeagues + 1 as UInt64

        // return the new League
        return <- AthletaverseLeague.createNewLeague(ID: ID, name: name, rosterSize: rosterSize)
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
        // Initialize the contract with no Leagues or Teams
        self.totalLeagues = 0
        self.totalTeams = 0

        // TODO: Save Admin resource using init singleton pattern
        //
        // Doesn't work with CLI tooling yet:
        // https://github.com/onflow/flow-cli/issues/79
    }
}
