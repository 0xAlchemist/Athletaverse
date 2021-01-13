// The main Athletaverse contract
//
// This smart contract manages global state for the Athletaverse
//
// TODO: Explain sports and league creation once prototyped
// 

pub contract Athletaverse {

    // emitted when the contract is initialized
    pub event AthletaverseInitialized()

    // totalLeagues represents the total number of Leagues that have been created
    pub var totalLeagues: UInt64

    // totalTeams represents the total number of Teams that have been created
    pub var totalTeams: UInt64

    // TODO: Update Flow CLI to version that supports Enums
    // sports is an Enum representing the available sport types - used to determine equipment type
    // pub var sports: Enum

    // commissioners is a dictionary that maps each league ID to it's owner's Flow address
    //
    // - Leagues are a resource that will be stored in the commissioner's account storage,
    // so we need an easy way to find out where each league is stored. 
    pub var commissioners: {UInt64: Address}

    // teamOwners is a dictionary that maps each team ID to it's owner's Flow address
    //
    // - Teams are a resource that will be stored in the owner's account storage,
    // so we need an easy way to find out where each team is stored. 
    pub var teamOwners: {UInt64: Address}
    
    // TODO: This should be 'admin only' - could make this something users need to
    // 'unlock' via purchase, or by committing their initial prize Vault to prevent
    // spam League creation
    // 
    // createNewLeague creates a new League resource and returns it to the caller
    pub fun createNewLeague(name: String): @AthletaverseLeague.League {
        
        // set the league ID to the total number of leagues
        let ID = Athletaverse.totalLeagues

        // increment the total number of leagues by one
        Athletaverse.totalLeagues = Athletaverse.totalLeagues + 1 as UInt64

        // return the new League
        return <- create AthletaverseLeague.League(ID: ID, name: name)
    }

    // createNewTeam creates a new Team resource and returns it to the caller
    pub fun createNewTeam(teamName: String): @AthletaverseTeam.Team {
        
        // set the total Teams count as the teamID
        let teamID = Athletaverse.totalTeams

        // increment the totalTeams count by one
        Athletaverse.totalTeams = Athletaverse.totalTeams + 1 as UInt64
        
        // return the new Team to the caller
        return <- create AthletaverseTeam.Team(ID: teamID, name: teamName)
    }

    init() {
        // Initialize the contract with no Leagues or Teams
        self.totalLeagues = 0
        self.totalTeams = 0

        self.commissioners = {}
        self.teamOwners = {}
    }
}
