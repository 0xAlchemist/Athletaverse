import NonFungibleToken from "./onflow/NonFungibleToken.cdc"
import AthletaverseUtils from "./AthletaverseUtils.cdc"
import AthletaverseTeam from "./AthletaverseTeam.cdc"

// LEAGUE
//
// A League allows a group of Teams to compete against eachother for a championship reward
// at the end of each recurring Season

pub contract AthletaverseLeague: NonFungibleToken {

    // total amount of Leagues minted
    pub var totalSupply: UInt64

    // LeagueMinter paths
    pub var leagueMinterStoragePath: StoragePath
    pub var leagueMinterPrivatePath: PrivatePath

    // LeagueSuperAdmin paths
    pub var leagueSuperAdminStoragePath: StoragePath
    pub var approvedLeagueMinterPrivatePath: PrivatePath
    
    // Collection paths
    pub var leagueCollectionStoragePath: StoragePath
    pub var leagueCollectionPublicPath: PublicPath

    // events from the NFT standard
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    
    // emitted when a new League is created
    pub event NewLeagueCreated(_ ID: UInt64)

    // emitted when a new LeagueMinter has been approved
    pub event NewLeagueMinterCreated(_ account: Address)
    
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

    // Leagues are a resource that represents a collection of Teams.
    pub resource NFT: NonFungibleToken.INFT {

        // each League has a unique ID
        pub let id: UInt64

        // each League has a human readable name
        pub let name: String

        // teams maps the ID for each Team registered to the league to it's Capability
        // TODO: define the capability type
        pub let teams: @AthletaverseUtils.QueuedCapabilityManager

        init(ID: UInt64, name: String, rosterSize: Int) {
            self.id = ID
            self.name = name
            self.teams <- AthletaverseUtils.newQueuedCapabilityManager(limit: rosterSize)

            emit NewLeagueCreated(ID)
        }

        // registerTeam adds a Team's public capability to the approval queue
        //
        pub fun registerTeam(teamCapability: Capability) {
            if let team = teamCapability.borrow<&AthletaverseTeam.Team>() {
                self.teams.addCapability(id: team.ID, capability: teamCapability)

                emit TeamRegisteredToLeague(teamID: team.ID, leagueID: self.id)
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

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @AthletaverseLeague.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // create an empty Collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // creates a collection, saves it to the signer's account storage
    // and links a public capability to the CollectionPublic interface
    //
    access(contract) fun setupAccountCollection(_ signer: AuthAccount) {
        let collection <- self.createEmptyCollection()

        signer.save(<-collection, to: self.leagueCollectionStoragePath)

        signer.link<&Collection{NonFungibleToken.CollectionPublic}>(
            self.leagueCollectionPublicPath,
            target: self.leagueCollectionStoragePath
        )
    }

    pub fun requestLeagueMintingCapability(signer: AuthAccount) {
        // setup the league Collection
        self.setupAccountCollection(signer)

        // TODO: setup capability receiver

        emit NewLeagueMinterRequested(signer.address)
    }

    // allows the owner of the resource to mint a new League NFT
    pub resource LeagueMinter {
        // mint a new league and return it to the caller
        pub fun createNewLeague(name: String, rosterSize: Int): @AthletaverseLeague.NFT {
            
            // Increment the totalSupply to get the League ID
            var ID = AthletaverseLeague.totalSupply + 1 as UInt64

            // Update the total supply to include the new League
            AthletaverseLeague.totalSupply = ID

            emit NewLeagueCreated(ID)

            // return the new League
            return <- create NFT(ID: ID, name: name, rosterSize: rosterSize)
        }
    }

    // The ApprovedLeagueMinter capability will be provided to
    // accounts that have been approved to create new Leagues
    //
    pub resource interface ApprovedLeagueMinter {
        pub fun createLeagueMinter(signer: AuthAccount)
    }

    // Allows owner to create a new LeagueMinter resource
    pub resource LeagueSuperAdmin: ApprovedLeagueMinter {

        // returns a new LeagueMinter resource to the caller
        //
        // TODO: going to need a capability receiver here
        // to pass this functionality to an approved caller
        pub fun createLeagueMinter(signer: AuthAccount) {
            
            let minter <- create LeagueMinter()
            
            signer.save(<- minter, to: /storage/AthletaverseLeagueMinter)

            signer.link<&LeagueMinter>(
                AthletaverseLeague.leagueMinterPrivatePath,
                target: AthletaverseLeague.leagueMinterStoragePath
            )

            emit NewLeagueMinterCreated(signer.address)
        }
    }

    init() {

        // Set initial total supply to zero
        self.totalSupply = 0 as UInt64

        // Setup reusable paths for the LeagueMinter resource
        self.leagueMinterStoragePath = /storage/AthletaverseLeagueMinter
        self.leagueMinterPrivatePath = /private/AthletaverseLeagueMinter
        
        // Setup reusable paths for the LeagueSuperAdmin resource
        self.leagueSuperAdminStoragePath = /storage/AthletaverseLeagueSuperAdmin
        self.approvedLeagueMinterPrivatePath = /private/approvedLeagueMinter
        
        // Setup reusable paths for the Collection resource
        self.leagueCollectionStoragePath = /storage/AthletaverseLeagueCollection
        self.leagueCollectionPublicPath = /public/AthletaverseLeagueCollection

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