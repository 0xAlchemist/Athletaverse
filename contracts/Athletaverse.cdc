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
    pub var commissioners: {UInt64: Address}

    pub resource League {

        // Each League has a unique ID
        pub let ID: UInt64

        init(ID: UInt64) {
            self.ID = ID
        }
    }

    init() {
        self.numLeagues = 0
        self.commissioners = {}
    }
}