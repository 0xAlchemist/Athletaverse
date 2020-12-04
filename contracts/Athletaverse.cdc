// The main Athletaverse contract
//
// This smart contract manages global state for the Athletaverse
//
// TODO: Explain sports and league creation once prototyped
// 
// TODO: Add Collections for League and Team resource - are they NFTs or just similar resources?
pub contract Athletaverse {

    // emitted when the contract is initialized
    pub event AthletaverseInitialized(totalLeagues: UInt64, totalTeams: UInt64)

    // emitted when a new League is created
    pub event NewLeagueCreated(ID: UInt64, name: String)

    // emitted when a new Team is created
    pub event NewTeamCreated(ID: UInt64, name: String)

    // emitted whenever a Team name is changed
    pub event TeamNameUpdated(ID: UInt64, previousName: String, newName: String)

    // emitted whenever an Athlete is added to a Team
    pub event AthleteAddedToTeam(teamID: UInt64, athleteID: UInt64)

    // emitted whenever an Athlere is removed from a Team
    pub event AthleteRemovedFromTeam(teamID: UInt64, athleteID: UInt64)

    // emitted when a Team has requested registeration to a League
    pub event TeamRegistrationRequested(teamID: UInt64, leagueID: UInt64)
    
    // emitted when a Team has been registered to a League
    pub event TeamRegisteredToLeague(teamID: UInt64, leagueID: UInt64)
    
    // emitted when a Team has been denied registration to a League
    pub event TeamRegistrationDenied(teamID: UInt64, leagueID: UInt64)

    // emitted when a Team has been removed from a League
    pub event TeamRemovedFromLeague(teamID: UInt64, leagueID: UInt64)

    // totalLeagues represents the total number of Leagues that have been created
    access(contract) var totalLeagues: UInt64

    // totalTeams represents the total number of Teams that have been created
    access(contract) var totalTeams: UInt64

    // TODO: Update Flow CLI to version that supports Enums
    // sports is an Enum representing the available sport types - used to determine equipment type
    // pub var sports: Enum

    // commissioners is a dictionary that maps each league ID to it's owner's Flow address
    //
    // - Leagues are a resource that will be stored in the commissioner's account storage,
    // so we need an easy way to find out where each league is stored. 
    access(contract) var commissioners: {UInt64: Address}

    // teamOwners is a dictionary that maps each league ID to it's owner's Flow address
    //
    // - Teams are a resource that will be stored in the owner's account storage,
    // so we need an easy way to find out where each team is stored. 
    access(contract) var teamOwners: {UInt64: Address}

    // LEAGUE
    //
    // A League allows a group of Teams to compete against eachother for a championship reward
    // at the end of each recurring Season
    pub resource League {

        // Each League has a unique ID
        access(account) let ID: UInt64

        // Each League has a human readable name
        access(account) let name: String

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capability type
        access(account) let teams: {UInt64: Capability?}

        access(account) let requests: {UInt64: Capability?}

        init(ID: UInt64, name: String) {
            self.ID = ID
            self.name = name
            self.teams = {}
            self.requests = {}

            emit NewLeagueCreated(ID: ID, name: name)
        }

        // registerTeam adds a Team's public capability to the League
        //
        // - this allows the Team to participate in the League's activities
        //
        pub fun requestRegisterTeam(teamCapability: Capability) {
            if let team = teamCapability.borrow<&Team>() {
                self.requests[team.ID] = teamCapability

                emit TeamRegistrationRequested(teamID: team.ID, leagueID: self.ID)
            } else {
                log("Unable to get Team ID. Request was not completed.")
            }
        }

        // approveRegisterTeam adds a Team's public capability to the League
        //
        // - this allows the Team to participate in the League's activities
        //
        pub fun approveRegisterTeam(teamID: UInt64) {
            pre {
                // terminate if no request exists for the given Team ID
                self.requests[teamID] != nil : "Team has not requested to register"
            }
            
            // add the capability to the teams dictionary
            self.teams[teamID] = self.requests[teamID]
            
            // remove the capability from the requests dictionary
            self.requests[teamID] = nil
            
            // emit the event
            emit TeamRegisteredToLeague(teamID: teamID, leagueID: self.ID)
        }

        // denyRegisterTeam removes the team from the requests dictionary
        //
        // - this allows the Team to participate in the League's activities
        //
        pub fun denyRegisterTeam(teamID: UInt64) {
            pre {
                // revert if no request exists for the given Team ID
                self.requests[teamID] != nil : "Team has not requested to register"
            }
            
            // remove the capability from the requests dictionary
            self.requests[teamID] = nil

            // emit the event
            emit TeamRegistrationDenied(teamID: teamID, leagueID: self.ID)
        }
        
        // removeTeam removes the Team's public capability from the League
        //
        // - this team will no longer be able to participate in the League's activities
        //
        access(self) fun removeTeam(ID: UInt64) {

            // remove the capability from the teams dictionary
            self.teams[ID] = nil

            // emit the event
            emit TeamRemovedFromLeague(teamID: ID, leagueID: self.ID)
        }

        // getRequestIDs returns an array of Team IDs that have registered to
        // the league
        //
        pub fun getRequestIDs(): [UInt64] {
            return self.requests.keys
        }

        // getTeamIDs returns an array of Team IDs that have registered to
        // the league
        //
        pub fun getTeamIDs(): [UInt64] {
            return self.teams.keys
        }
    }
    
    // TODO: This should be 'admin only' - could make this something users need to
    // 'unlock' via purchase, or by committing their initial prize Vault to prevent
    // spam League creation
    // 
    // createNewLeague creates a new League resource and returns it to the caller
    pub fun createNewLeague(name: String): @League {
        
        // set the league ID to the total number of leagues
        let ID = Athletaverse.totalLeagues

        // increment the total number of leagues by one
        Athletaverse.totalLeagues = Athletaverse.totalLeagues + 1 as UInt64

        // return the new League
        return <- create League(ID: ID, name: name)
    }

    // TEAM
    //
    // A team contains a roster of athletes that play in matches
    pub resource Team {

        // each team has a unique ID
        access(account) let ID: UInt64

        // team name
        access(account) var name: String

        // resource dictionary that contains athlete/player NFT capabilities
        access(account) var roster: {UInt64: Capability?}

        init(ID: UInt64, name: String) {
            self.ID = ID
            self.name = name
            self.roster = {}

            emit NewTeamCreated(ID: ID, name: name)
        }

        // updateTeamName sets the Team name to the provided value
        access(self) fun updateTeamName(_ name: String) {
            
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
        access(self) fun addAthleteToTeam(ID: UInt64, athleteCapability: Capability) {
            self.roster[ID] = athleteCapability

            emit AthleteAddedToTeam(teamID: self.ID, athleteID: ID)
        }

        // removeAthleteFromTeam removes an athlete's public capability from the Team roster
        //
        // - the Athlete can no longer participate in Team activities
        access(self) fun removeAthleteFromTeam(ID: UInt64) {
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

        emit AthletaverseInitialized(totalLeagues: self.totalLeagues, totalTeams: self.totalTeams)
    }
}
