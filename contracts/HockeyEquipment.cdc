// Equipment NFT

// Equipment provides the core stats for an athlete.

// Core skater stats are:
// - Skating (Speed/Agility)
// - Shooting
// - Hands (Dangles/Sauce)
// - Checking

// Core goalie stats are:
// - Glove
// - Blocker
// - High
// - Low

import NonFungibleToken from 0x01cf0e2f2f715450

pub contract HockeyEquipment: NonFungibleToken {
    
    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        // TODO: Make this a custom struct!!!
        pub var metadata: {String: String}

        init(initID: UInt64) {
            self.id = initID
            self.metadata = {}
        }
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with a UInt64 ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @HockeyEquipment.NFT

            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @HockeyEquipment.Collection {
        return <- create Collection()
    }

    pub resource Equipminter {
        pub fun mintEquip(recipient: &{NonFungibleToken.CollectionPublic}) {

            var newNFT <- create NFT(initID: HockeyEquipment.totalSupply)

            recipient.deposit(token: <-newNFT)

            HockeyEquipment.totalSupply = HockeyEquipment.totalSupply + UInt64(1)
        }
    }

    init() {
        self.totalSupply = 0

        let collection <- create Collection()
        self.account.save(<-collection, to: /storage/EquipmentCollection)

        self.account.link<&{NonFungibleToken.CollectionPublic}>(
            /public/EquipmentCollection,
            target: /storage/EquipmentCollection
        )

        let minter <- create Equipminter()
        self.account.save(<-minter, to: /storage/Equipminter)

        emit ContractInitialized()
    }
}