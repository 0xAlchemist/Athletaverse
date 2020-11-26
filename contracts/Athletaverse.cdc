// The main Athletaverse contract
//
// This smart contract manages global state for the Athletaverse
// 

pub contract Athletaverse {

    // numLeagues represents the total number of leagues that have been created
    pub var numLeagues: UInt64

    // TODO: Update Flow CLI to version that supports Enums
    // sports is an Enum representing the available sport types - used to determine equipment type
    // pub var sports: Enum

    // commissioners is a dictionary that maps each league ID to it's owner's Flow address
    //
    // - Leagues are a resource that will be stored in the commissioner's account storage,
    // so we need an easy way to find out where each league is stored. 
    pub var commissioners: {UInt64: Address}

    // A League allows a group of Teams to compete against eachother for a championship reward
    // at the end of each recurring Season
    pub resource League {

        // Each League has a unique ID
        pub let ID: UInt64

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capabibility type
        pub let teams: {UInt64: Capability?}

        init(ID: UInt64) {
            self.ID = ID
            self.teams = {}
        }

        // registerTeam adds a Team's public capability to the League
        //
        // - this allows the Team to participate in the League's activities
        //
        pub fun registerTeam(ID: UInt64, teamCapability: Capability) {
            self.teams[ID] = teamCapability
        }
        
        // removeTeam removes the Team's public capability from the League
        //
        // - this team will no longer be able to participate in the League's activities
        //
        pub fun removeTeam(ID: UInt64) {
            self.teams[ID] = nil
        }
    }

    init() {
        self.numLeagues = 0
        self.commissioners = {}
    }
}