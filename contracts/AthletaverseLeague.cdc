import AthletaverseUtils from "./AthletaverseUtils.cdc"
import AthletaverseTeam from "./AthletaverseTeam.cdc"

// LEAGUE//
// A League allows a group of Teams to compete against eachother for a championship reward
// at the end of each recurring Season

pub contract AthletaverseLeague {

    // total amount of Leagues minted
    pub var totalSupply: UInt64

    // LeagueMinter paths
    pub let leagueMinterStoragePath: StoragePath
    pub let leagueMinterPrivatePath: PrivatePath
    pub let lockedLeagueMinterPublicPath: PublicPath

    // LeagueSuperAdmin paths
    pub let leagueSuperAdminStoragePath: StoragePath
    pub let approvedLeagueMinterPrivatePath: PrivatePath
    
    // Collection paths
    pub let leagueCollectionStoragePath: StoragePath
    pub let leagueCollectionPublicPath: PublicPath
    pub let leagueCollectionManagerPrivatePath: PrivatePath

    // events from the NFT standard
    pub event ContractInitialized()
    pub event Deposit(id: UInt64, to: Address?)
    
    // emitted when a new League is created
    pub event NewLeagueCreated(_ ID: UInt64, name: String)

    // emitted when a new LeagueMinter has been approved
    pub event NewLeagueMinterApproved(_ account: Address)
    
    // emitted when a new LeagueMinter capability has been created
    pub event NewLeagueMinterRequested(_ account: Address)

    // emitted when a Team has been registered to a League
    pub event TeamRegisteredToLeague(teamID: UInt64, leagueID: UInt64)

    // emitted when a Team has been removed from a League
    pub event TeamRemovedFromLeague(teamID: UInt64, leagueID: UInt64)

    // emitted when the league owner approves a new Team
    pub event AddTeamApproved(teamID: UInt64, leagueID: UInt64)
    
    // emitted when the league owner rejects a new Team
    pub event AddTeamRejected(teamID: UInt64, leagueID: UInt64)

    // provides access to admin methods for managing the League
    pub resource interface LeagueManager {
        pub fun registerTeam(teamCapability: Capability)
        pub fun approveTeam(_ id: UInt64)
        pub fun rejectTeam(_ id: UInt64)
        pub fun removeTeam(_ id: UInt64)
        pub fun getTeamIDs(): [UInt64]
        pub fun getTeamInfo(): {UInt64: String}
    }

    // provides access to public League methods 
    pub resource interface LeaguePublic {
        pub fun registerTeam(teamCapability: Capability)
        pub fun getTeamIDs(): [UInt64]
        pub fun getTeamInfo(): {UInt64: String}
    }

    // Leagues are a resource that represents a collection of Teams.
    pub resource Token: LeagueManager, LeaguePublic {

        // each League has a unique ID
        pub let id: UInt64

        // each League has a human readable name
        pub let name: String

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capability type
        pub let teams: @AthletaverseUtils.RegisteredCapabilityManager

        init(name: String, rosterSize: Int) {
            self.id = AthletaverseLeague.totalSupply + 1 as UInt64
            self.name = name
            self.teams <- AthletaverseUtils.newRegisteredCapabilityManager(limit: rosterSize)

            emit NewLeagueCreated(self.id, name: name)
        }

        // registerTeam adds a Team's public capability to the approval queue
        //
        pub fun registerTeam(teamCapability: Capability) {
            if let team = teamCapability.borrow<&{AthletaverseTeam.TeamPublic}>() {
                self.teams.addCapability(id: team.id, capability: teamCapability)

                emit TeamRegisteredToLeague(teamID: team.id, leagueID: self.id)
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
            
            emit AddTeamApproved(teamID: id, leagueID: self.id)
        }

        // rejectTeam removes a Team's public capability from the League
        //
        // TODO: Should only be called by league admin
        pub fun rejectTeam(_ id: UInt64) {
            self.teams.rejectRequest(id)

            emit AddTeamRejected(teamID: id, leagueID: self.id)
        }
        
        // removeTeam removes the Team's public capability from the League
        //
        // - this team will no longer be able to participate in the League's activities
        //
        // TODO: Should only be called by league admin
        pub fun removeTeam(_ id: UInt64) {
            self.teams.removeCapability(id)

            emit TeamRemovedFromLeague(teamID: id, leagueID: self.id)
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
                if let teamReference = self.teams.approved[id]!!.borrow<&{AthletaverseTeam.TeamPublic}>() {
                    
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

    pub resource interface CollectionPublic {
        pub fun deposit(token: @Token)
        pub fun getIDs(): [UInt64]
        pub fun borrowLeague(id: UInt64): &Token{LeaguePublic}?
    }

    pub resource interface CollectionManager {
        pub fun getIDs(): [UInt64]
        pub fun borrowLeague(id: UInt64): &Token{LeaguePublic}?
        pub fun borrowManager(id: UInt64): &Token{LeagueManager}?
    }

    pub resource Collection: CollectionPublic, CollectionManager {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedLeagues: @{UInt64: Token}

        init () {
            self.ownedLeagues <- {}
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @Token) {
            let token <- token as @Token

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedLeagues[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedLeagues.keys
        }

        // borrowLeague gets a reference to a League Token {LeaguePublic} in the collection
        // so that the caller can use its League specific metadata and methods
        pub fun borrowLeague(id: UInt64): &Token{LeaguePublic}? {
            return &self.ownedLeagues[id] as! &Token{LeaguePublic}
        }

        // borrowManager gets a reference to a League Token {LeagueManager} in the collection
        // so that the owner can manage the League
        pub fun borrowManager(id: UInt64): &Token{LeagueManager}? {
            return &self.ownedLeagues[id] as! &Token{LeagueManager}
        }

        destroy() {
            destroy self.ownedLeagues
        }
    }

    // create an empty Collection
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    // creates a collection, saves it to the signer's account storage
    // and links a public capability to the CollectionPublic interface
    //
    access(contract) fun setupAccountCollection(_ signer: AuthAccount) {
        let collection <- self.createEmptyCollection()

        signer.save(<-collection, to: self.leagueCollectionStoragePath)

        signer.link<&Collection{CollectionPublic}>(
            self.leagueCollectionPublicPath,
            target: self.leagueCollectionStoragePath
        )

        signer.link<&Collection{CollectionManager}>(
            self.leagueCollectionManagerPrivatePath,
            target: self.leagueCollectionStoragePath
        )
    }

    // returns true or false depending on whether the League collection has been setup
    // in the signer's account
    access(contract) fun hasAccountCollection(_ signer: PublicAccount): Bool {
        let collectionCapability = signer.getCapability<&{CollectionPublic}>
            (AthletaverseLeague.leagueCollectionPublicPath)

        return collectionCapability.check()
    }

    // adds the signer to the LeagueMinter requests dictionary for Super Admin approval
    pub fun requestLeagueMintingCapability(_ signer: AuthAccount) {
        // setup the league Collection
        self.setupAccountCollection(signer)

        // TODO: setup capability receiver
        let minter <- create LeagueMinter()
            
        signer.save(<- minter, to: /storage/AthletaverseLeagueMinter)

        signer.link<&LeagueMinter>(
            AthletaverseLeague.leagueMinterPrivatePath,
            target: AthletaverseLeague.leagueMinterStoragePath
        )

        signer.link<&LeagueMinter{LockedLeagueMinter}>(
            AthletaverseLeague.lockedLeagueMinterPublicPath,
            target: AthletaverseLeague.leagueMinterStoragePath
        )

        emit NewLeagueMinterRequested(signer.address)
    }

    pub resource interface LockedLeagueMinter {
        pub fun addLeagueMintingCapability(_ capability: Capability<&LeagueSuperAdmin{ApprovedLeagueMinter}>)
    }

    // allows the owner of the resource to mint a new League NFT
    pub resource LeagueMinter: LockedLeagueMinter, ApprovedLeagueMinter {
        
        access(self) var createLeagueCapability : Capability<&LeagueSuperAdmin{ApprovedLeagueMinter}>?

        init() {
            self.createLeagueCapability = nil
        }

        pub fun addLeagueMintingCapability(_ capability: Capability<&LeagueSuperAdmin{ApprovedLeagueMinter}>) {
            pre {
                capability.borrow() != nil: "Invalid ApprovedLeagueMinter capability"
            }

            self.createLeagueCapability = capability

            emit NewLeagueMinterApproved(self.owner!.address)
        }

        pub fun createNewLeague(name: String, rosterSize: Int) {

            pre {
                self.owner != nil: "This resource has no owner"
                AthletaverseLeague.hasAccountCollection(self.owner!) == true: "Account has no League Collection"
                self.createLeagueCapability != nil: "Can not create a league until approved by the Super Admin"
            }

            // create a new League NFT
            let league <- create Token(name: name, rosterSize: rosterSize)

            // get the LeagueMinter resource owner's CollectionPublic capability
            let collectionCapability = self.owner!.getCapability<&Collection{CollectionPublic}>
                                            (AthletaverseLeague.leagueCollectionPublicPath)

            // borrow a reference to the CollectionPublic capability
            let collectionReference = collectionCapability.borrow()

            // deposit the League NFT into the LeagueMinter resource owner's collection
            collectionReference!.deposit(token: <-league)
        }

    }

    // The ApprovedLeagueMinter capability will be provided to
    // accounts that have been approved to create new Leagues
    pub resource interface ApprovedLeagueMinter {
        pub fun createNewLeague(name: String, rosterSize: Int)
    }

    // Allows owner to create a new LeagueMinter resource
    pub resource LeagueSuperAdmin: ApprovedLeagueMinter {

        // mint a new league and return it to the caller
        pub fun createNewLeague(name: String, rosterSize: Int) {

            pre {
                self.owner != nil: "This resource has no owner"
                AthletaverseLeague.hasAccountCollection(self.owner!) == true: "Account has no League Collection" 
            }

            // create a new League NFT
            let league <- create Token(name: name, rosterSize: rosterSize)

            // get the Super Admin's CollectionPublic capability
            let collectionCapability = self.owner!.getCapability<&Collection{CollectionPublic}>
                                            (AthletaverseLeague.leagueCollectionPublicPath)

            // borrow a reference to the CollectionPublic capability
            let collectionReference = collectionCapability.borrow()

            // deposit the League NFT into the Super Admin's collection
            collectionReference!.deposit(token: <-league)
        }

    }

    init() {

        // Set initial total supply to zero
        self.totalSupply = 0 as UInt64

        // Setup reusable paths for the LeagueMinter resource
        self.leagueMinterStoragePath = /storage/AthletaverseLeagueMinter
        self.leagueMinterPrivatePath = /private/AthletaverseLeagueMinter
        
        // Setup reusable paths for the LockedLeagueMinter capability=
        self.lockedLeagueMinterPublicPath = /public/AthletaverseLockedLeagueMinter
        
        // Setup reusable paths for the LeagueSuperAdmin resource
        self.leagueSuperAdminStoragePath = /storage/AthletaverseLeagueSuperAdmin
        self.approvedLeagueMinterPrivatePath = /private/approvedLeagueMinter
        
        // Setup reusable paths for the Collection resource
        self.leagueCollectionStoragePath = /storage/AthletaverseLeagueCollection
        self.leagueCollectionPublicPath = /public/AthletaverseLeagueCollection
        self.leagueCollectionManagerPrivatePath = /private/AthletaverseLeagueCollectionManager

        // Setup the Admin with (slightly modified for tooling) init singleton
        // - prevents additional LeagueSuperAdmin resources
        // - https://docs.onflow.org/cadence/design-patterns/#init-singleton

        // Create the LeagueSuperAdmin resource
        let superAdmin <- create LeagueSuperAdmin()

        // Save the resource to the initializer's account storage
        self.account.save(<-superAdmin, to: AthletaverseLeague.leagueSuperAdminStoragePath)

        // Link a private capability to the LeagueSuperAdmin resource
        self.account.link<&LeagueSuperAdmin{ApprovedLeagueMinter}>(
            AthletaverseLeague.approvedLeagueMinterPrivatePath,
            target: AthletaverseLeague.leagueSuperAdminStoragePath
        )

        // Setup the initializer's League Collection
        self.setupAccountCollection(self.account)

        emit ContractInitialized()
    }
}