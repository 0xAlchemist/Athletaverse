// Sports Equipment NFT

// Sports Equipment provides stat multipliers for an athlete.
import NonFungibleToken from 0x01cf0e2f2f715450

pub contract SportsEquipment: NonFungibleToken {
    
    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event NewEquipmentMinted(id: UInt64, type: String, rarity: Int, stat: String, multiplier: UFix64)

    // Meta stores the metadata for a piece of SportsEquipment
    pub struct Meta {
        pub let type: String
        pub let rarity: Int
        pub let stat: String
        pub let multiplier: UFix64

        init(type: String, rarity: Int, stat: String, multiplier: UFix64) {
            self.type = type
            self.rarity = rarity
            self.stat = stat
            self.multiplier = multiplier
        }
    }

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub var metadata: Meta

        init(initID: UInt64, meta: Meta) {
            self.id = initID
            self.metadata = meta
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
            let token <- token as! @SportsEquipment.NFT

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

    pub fun createEmptyCollection(): @SportsEquipment.Collection {
        return <- create Collection()
    }

    pub resource Equipminter {
        pub fun mintEquip(recipient: &{NonFungibleToken.CollectionPublic}, type: String, rarity: Int, stat: String, multiplier: UFix64) {
            
            let tokenID = SportsEquipment.totalSupply
            let meta = Meta(type: type, rarity: rarity, stat: stat, multiplier: multiplier)
            var newNFT <- create NFT(initID: tokenID, meta: meta)
            
            recipient.deposit(token: <-newNFT)

            SportsEquipment.totalSupply = SportsEquipment.totalSupply + 1 as UInt64
            
            emit NewEquipmentMinted(id: tokenID, type: meta.type, rarity: meta.rarity, stat: meta.stat, multiplier: meta.multiplier)
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
