// LEAGUE
//
// A League allows a group of Teams to compete against eachother for a championship reward
// at the end of each recurring Season

pub contract AthletaverseLeague {
    
    // emitted when a new League is created
    pub event NewLeagueCreated(_ ID: UInt64)

    // emitted when a Team has been registered to a League
    pub event TeamRegisteredToLeague(teamID: UInt64, leagueID: UInt64)

    // emitted when a Team has been removed from a League
    pub event TeamRemovedFromLeague(teamID: UInt64, leagueID: UInt64)

    pub resource League {

        // Each League has a unique ID
        pub let ID: UInt64

        // Each League has a human readable name
        pub let name: String

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capability type
        pub let teams: {UInt64: Capability?}

        init(ID: UInt64, name: String) {
            self.ID = ID
            self.name = name
            self.teams = {}

            emit NewLeagueCreated(ID)
        }

        // registerTeam adds a Team's public capability to the League
        //
        // - this allows the Team to participate in the League's activities
        //
        pub fun registerTeam(teamCapability: Capability) {
            if let team = teamCapability.borrow<&Team>() {
                self.teams[team.ID] = teamCapability
            } else {
                log("Unable to get Team ID. Team was not registered")
            }
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

    init() {}
}