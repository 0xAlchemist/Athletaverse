import AthletaverseTeam from "./AthletaverseTeam.cdc"

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

    // Leagues are a resource that represents a collection of Teams.
    pub resource League {

        // each League has a unique ID
        pub let ID: UInt64

        // each League has a human readable name
        pub let name: String

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capability type
        pub let teams: {UInt64: Capability?}

        // max amount of players per team
        pub let rosterSize: Int

        init(ID: UInt64, name: String, rosterSize: Int) {
            self.ID = ID
            self.name = name
            self.teams = {}
            self.rosterSize = rosterSize

            emit NewLeagueCreated(ID)
        }

        // registerTeam adds a Team's public capability to the League
        //
        // - this allows the Team to participate in the League's activities
        //
        pub fun registerTeam(teamCapability: Capability) {
            if let team = teamCapability.borrow<&AthletaverseTeam.Team>() {
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

        pub fun getTeamInfo(): {UInt64: String} {
            let teamIDs = self.getTeamIDs()
            var teamInfo: {UInt64: String} = {}

            for id in teamIDs {
                if let teamReference = self.teams[id]!!.borrow<&AthletaverseTeam.Team>() {
                    teamInfo[id] = teamReference.getTeamName()   
                }
            }

            return teamInfo
        }
    }

    pub fun createNewLeague(ID: UInt64, name: String, rosterSize: Int): @League {
        // return the new League
        return <- create League(ID: ID, name: name, rosterSize: rosterSize)
    }

    init() {}
}