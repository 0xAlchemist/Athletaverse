    // TEAM
    //
    // A team contains a roster of athletes that play in matches

    pub contract AthletaverseTeam {

        // the total Teams in circulation
        pub var totalSupply: UInt64

        // Resource Storage Paths
        pub let minterStoragePath: StoragePath
        pub let teamStoragePath: StoragePath

        // Private Capability Paths
        pub let minterPrivatePath: PrivatePath
        pub let teamManagerPath: PrivatePath

        // Public Capability Paths
        pub let teamPublicPath: PublicPath

        // From the NFT standard
        pub event ContractInitialized()
        
        // emitted when a new Team is created
        pub event NewTeamCreated(ID: UInt64, name: String)

        // emitted whenever a Team name is changed
        pub event TeamNameUpdated(ID: UInt64, previousName: String, newName: String)

        // emitted whenever an Athlete is added to a Team
        pub event AthleteAddedToTeam(teamID: UInt64, athleteID: UInt64)

        // emitted whenever an Athlere is removed from a Team
        pub event AthleteRemovedFromTeam(teamID: UInt64, athleteID: UInt64)

        // only used to manage the team <-> league relationship.
        //
        pub resource interface TeamPublic {
            // this is used to link the public capability
            // that is used to register a team
            //
            pub let id: UInt64

            pub fun getTeamName(): String
        }

        pub resource interface TeamManager {
            // TODO: Add private methods
            pub let id: UInt64
        }

        // Teams are a resource are a resource that represents a roster of Athlete NFTs. 
        // Teams can also be assigned to Leagues.
        pub resource Asset: TeamPublic, TeamManager {

            // each team has a unique ID
            pub let id: UInt64

            // team name
            pub var name: String

            // resource dictionary that contains athlete/player NFTs 
            // TODO: (update with player NFT)
            pub var roster: {UInt64: Capability?}

            init(name: String) {

                // increment the totalSupply by one to create the team ID
                let newID = AthletaverseTeam.totalSupply + 1 as UInt64

                // update the total supply to include the new team
                AthletaverseTeam.totalSupply = newID
                
                self.id = newID
                self.name = name
                self.roster = {}

                emit NewTeamCreated(ID: newID, name: name)
            }

            // updateTeamName sets the Team name to the provided value
            pub fun updateTeamName(_ name: String) {
                
                // store the old name for the event
                let previousName = self.name
                
                // update the Team name
                self.name = name

                emit TeamNameUpdated(ID: self.id, previousName: previousName, newName: name)
            }

            // addAthleteToTeam adds an Athlete's public capability to the Team roster
            //
            // - allows the Athlete to participate in Team activities
            //
            pub fun addAthleteToTeam(_ ID: UInt64, athleteCapability: Capability) {
                self.roster[ID] = athleteCapability

                emit AthleteAddedToTeam(teamID: self.id, athleteID: ID)
            }

            // removeAthleteFromTeam removes an athlete's public capability from the Team roster
            //
            // - the Athlete can no longer participate in Team activities
            pub fun removeAthleteFromTeam(_ ID: UInt64) {
                self.roster[ID] = nil

                emit AthleteRemovedFromTeam(teamID: self.id, athleteID: ID)
            }

            // getID returns the Team ID
            pub fun getID(): UInt64 {
                return self.id
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

        // A resource that provides the owner with methods 
        // for managing the creation of Team NFTs
        //
        pub resource Minter {

            // TODO: Add Athletaverse Bank and Payment system
            //
            // Creates a new Team NFT and returns it to the caller
            pub fun createTeam(name: String): @Asset {
                return <- create Asset(name: name)
            }
        }

        pub fun createMinter(): @Minter {
            return <- create Minter()
        }

        init() {
            
            // init with zero teams
            self.totalSupply = 0

            // set the Storage paths
            self.minterStoragePath = /storage/AthletaverseTeamMinter
            self.teamStoragePath = /storage/AthletaverseTeamAsset

            // set the Private paths
            self.minterPrivatePath = /private/AthletaverseTeamMinter
            self.teamManagerPath = /private/AthletaverseTeamManager

            // set the public paths
            self.teamPublicPath = /public/AthletaverseTeamPublic

            // create a Team Minter resource for the Admin
            self.account.save(<- create Minter(), to: AthletaverseTeam.minterStoragePath)

            // link the TeamMinter capability to allow
            // the owner to borrow a reference to it
            //
            self.account.link<&Minter>(
                AthletaverseTeam.minterPrivatePath,
                target: AthletaverseTeam.minterStoragePath
            )
        }
    }