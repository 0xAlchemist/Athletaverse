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

    // emitted when the contract is initialized
    pub event ContractInitialized()

    // Event that is emitted when a token is withdrawn,
    // indicating the owner of the collection that it was withdrawn from.
    //
    // If the collection is not in an account's storage, `from` will be `nil`.
    //
    pub event Withdraw(id: UInt64, from: Address?)

    // Event that emitted when a token is deposited to a collection.
    //
    // It indicates the owner of the collection that it was deposited to.
    //
    pub event Deposit(id: UInt64, to: Address?)
    
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
    pub resource NFT: NonFungibleToken.INFT {

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

    // anyone can create an empty Collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // mint a new league and return it to the caller
    pub fun createNewLeague(name: String, rosterSize: Int): @NFT {
        
        // Increment the totalSupply to get the League ID
        var ID = self.totalSupply + 1 as UInt64

        // Update the total supply to include the new League
        self.totalSupply = ID

        // return the new League
        return <- create NFT(ID: ID, name: name, rosterSize: rosterSize)
    }
}