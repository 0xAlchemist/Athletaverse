    // TEAM
    //
    // A team contains a roster of athletes that play in matches

    pub contract AthletaverseTeam {
        
        // emitted when a new Team is created
        pub event NewTeamCreated(ID: UInt64, name: String)

        // emitted whenever a Team name is changed
        pub event TeamNameUpdated(ID: UInt64, previousName: String, newName: String)

        // emitted whenever an Athlete is added to a Team
        pub event AthleteAddedToTeam(teamID: UInt64, athleteID: UInt64)

        // emitted whenever an Athlere is removed from a Team
        pub event AthleteRemovedFromTeam(teamID: UInt64, athleteID: UInt64)

        // Teams are a resource are a resource that represents a roster of Athlete NFTs. 
        // Teams can also be assigned to Leagues.
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

        pub fun createNewTeam(ID: UInt64, name: String): @Team {
            // return the new Team to the caller
            return <- create Team(ID: ID, name: name)
        }

        init() {}
    }