import AthletaverseUtils from "./AthletaverseUtils.cdc"
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

    // emitted when the league owner approves a new Team
    pub event AddTeamApproved(teamID: UInt64, leagueID: UInt64)
    
    // emitted when the league owner rejects a new Team
    pub event AddTeamRejected(teamID: UInt64, leagueID: UInt64)

    // Leagues are a resource that represents a collection of Teams.
    pub resource League {

        // each League has a unique ID
        pub let ID: UInt64

        // each League has a human readable name
        pub let name: String

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capability type
        pub let teams: @AthletaverseUtils.QueuedCapabilityManager

        init(ID: UInt64, name: String, rosterSize: Int) {
            self.ID = ID
            self.name = name
            self.teams <- AthletaverseUtils.newQueuedCapabilityManager(limit: rosterSize)

            emit NewLeagueCreated(ID)
        }

        // registerTeam adds a Team's public capability to the approval queue
        //
        pub fun registerTeam(teamCapability: Capability) {
            if let team = teamCapability.borrow<&AthletaverseTeam.Team>() {
                self.teams.addCapability(id: team.ID, capability: teamCapability)

                emit TeamRegisteredToLeague(teamID: team.ID, leagueID: self.ID)
            } else {
                log("Unable to get Team ID. Team was not registered")
            }
        }
        
        // approveTeam adds a Team's public capability to the League
        //
        // - this allows the Team to participate in the League's activities
        //
        // TODO: Should only be called by league admin
        pub fun approveTeam(_ id: UInt64) {
            self.teams.approveRequest(id)
            
            emit AddTeamApproved(teamID: id, leagueID: self.ID)
        }

        // rejectTeam removes a Team's public capability from the League
        //
        // TODO: Should only be called by league admin
        pub fun rejectTeam(_ id: UInt64) {
            self.teams.rejectRequest(id)

            emit AddTeamRejected(teamID: id, leagueID: self.ID)
        }
        
        // removeTeam removes the Team's public capability from the League
        //
        // - this team will no longer be able to participate in the League's activities
        //
        // TODO: Should only be called by league admin
        pub fun removeTeam(_ id: UInt64) {
            self.teams.removeCapability(id)

            emit TeamRemovedFromLeague(teamID: id, leagueID: self.ID)
        }

        // getTeamIDs returns an array of Team IDs that have registered to
        // the league
        //
        pub fun getTeamIDs(): [UInt64] {
            return self.teams.approved.keys
        }

        // get TeamInfo returns a dictionary with basic team info {ID: name}
        pub fun getTeamInfo(): {UInt64: String} {
            let teamIDs = self.getTeamIDs()
            var teamInfo: {UInt64: String} = {}

            // for each team ID...
            for id in teamIDs {
                
                // ... if the Capability exists, borrow a reference to the Team
                if let teamReference = self.teams.approved[id]!!.borrow<&AthletaverseTeam.Team>() {
                    
                    // ... add the team name to the teamInfo dictionary
                    teamInfo[id] = teamReference.getTeamName()   
                }
            }

            return teamInfo
        }

        destroy () {
            destroy(self.teams)
        }
    }

    pub fun createNewLeague(ID: UInt64, name: String, rosterSize: Int): @League {
        // return the new League
        return <- create League(ID: ID, name: name, rosterSize: rosterSize)
    }
}