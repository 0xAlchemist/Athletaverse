// The main Athletaverse contract
//
// This smart contract manages global state for the Athletaverse
//
// TODO: Explain sports and league creation once prototyped
// 

pub contract Athletaverse {

    // emitted when the contract is initialized
    pub event AthletaverseInitialized()

    // emitted when a new League is created
    pub event NewLeagueCreated(_ ID: UInt64)

    // emitted when a new Team is created
    pub event NewTeamCreated(ID: UInt64, name: String)

    // emitted whenever a Team name is changed
    pub event TeamNameUpdated(ID: UInt64, previousName: String, newName: String)

    // emitted whenever an Athlete is added to a Team
    pub event AthleteAddedToTeam(teamID: UInt64, athleteID: UInt64)

    // emitted whenever an Athlere is removed from a Team
    pub event AthleteRemovedFromTeam(teamID: UInt64, athleteID: UInt64)

    // emitted when a Team has been registered to a League
    pub event TeamRegisteredToLeague(teamID: UInt64, leagueID: UInt64)

    // emitted when a Team has been removed from a League
    pub event TeamRemovedFromLeague(teamID: UInt64, leagueID: UInt64)

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

    // teamOwners is a dictionary that maps each league ID to it's owner's Flow address
    //
    // - Teams are a resource that will be stored in the owner's account storage,
    // so we need an easy way to find out where each team is stored. 
    pub var teamOwners: {UInt64: Address}

    // LEAGUE
    //
    // A League allows a group of Teams to compete against eachother for a championship reward
    // at the end of each recurring Season
    pub resource League {

        // Each League has a unique ID
        pub let ID: UInt64

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capability type
        pub let teams: {UInt64: Capability?}

        init(_ ID: UInt64) {
            self.ID = ID
            self.teams = {}

            emit NewLeagueCreated(ID)
        }

        // registerTeam adds a Team's public capability to the League
        //
        // - this allows the Team to participate in the League's activities
        //
        pub fun registerTeam(ID: UInt64, teamCapability: Capability) {
            self.teams[ID] = teamCapability

            emit TeamRegisteredToLeague(teamID: ID, leagueID: self.ID)
        }
        
        // removeTeam removes the Team's public capability from the League
        //
        // - this team will no longer be able to participate in the League's activities
        //
        pub fun removeTeam(ID: UInt64) {
            self.teams[ID] = nil

            emit TeamRemovedFromLeague(teamID: ID, leagueID: self.ID)
        }

        // getTeamIDs returns an array of Team IDs that have registered to
        // the league
        //
        pub fun getTeamIDs(): [UInt64] {
            return self.teams.keys
        }
    }

    // TODO: Should this be 'admin only' - could make this something users need to
    // 'unlock' via purchase, or by committing their initial prize Vault to prevent
    // spam League creation
    // 
    // createNewLeague creates a new League resource and returns it to the caller
    pub fun createNewLeague(): @League {
        
        // set the league ID to the total number of leagues
        let ID = Athletaverse.totalLeagues

        // increment the total number of leagues by one
        Athletaverse.totalLeagues = Athletaverse.totalLeagues + 1 as UInt64

        // return the new League
        return <- create League(ID)
    }

    // TEAM
    //
    // A team contains a roster of athletes that play in matches
    pub resource Team {

        // each team has a unique ID
        pub let ID: UInt64

        // team name
        pub var name: String

        // resource dictionary that contains athlete/player NFT capabilities
        pub var roster: {UInt64: Capability?}

        init(ID: UInt64, name: String) {
            self.ID = ID
            self.name = name
            self.roster = {}

            emit NewTeamCreated(ID: ID, name: name)
        }

        // updateTeamName sets the Team name to the provided value
        pub fun updateTeamName(_ name: String) {
            
            // store the old name for the event
            let previousName = self.name
            
            // update the Team name
            self.name = name

            emit TeamNameUpdated(ID: self.ID, previousName: previousName, newName: name)
        }

        // addAthleteToTeam adds an Athlete's public capability to the Team roster
        //
        // - allows the Athlete to participate in Team activities
        //
        pub fun addAthleteToTeam(ID: UInt64, athleteCapability: Capability) {
            self.roster[ID] = athleteCapability

            emit AthleteAddedToTeam(teamID: self.ID, athleteID: ID)
        }

        // removeAthleteFromTeam removes an athlete's public capability from the Team roster
        //
        // - the Athlete can no longer participate in Team activities
        pub fun removeAthleteFromTeam(ID: UInt64) {
            self.roster[ID] = nil

            emit AthleteRemovedFromTeam(teamID: self.ID, athleteID: ID)
        }

        // getID returns the Team ID
        pub fun getID(): UInt64 {
            return self.ID
        }

        // getTeamName returns the Team name
        pub fun getTeamName(): String {
            return self.name
        }

        // getAthleteIDs returns an array of Athlete NFT IDs
        pub fun getAthleteIDs(): [UInt64] {
            return self.roster.keys
        }
    }

    // createNewTeam creates a new Team resource and returns it to the caller
    pub fun createNewTeam(teamName: String): @Team {
        
        // set the total Teams count as the teamID
        let teamID = Athletaverse.totalTeams

        // increment the totalTeams count by one
        Athletaverse.totalTeams = Athletaverse.totalTeams + 1 as UInt64
        
        // return the new Team to the caller
        return <- create Team(ID: teamID, name: teamName)
    }

    init() {
        // Initialize the contract with no Leagues or Teams
        self.totalLeagues = 0
        self.totalTeams = 0

        self.commissioners = {}
        self.teamOwners = {}
    }
}