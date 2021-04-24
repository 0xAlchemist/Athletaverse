// The Athlete NFT contract

import NonFungibleToken from "../onflow/NonFungibleToken.cdc"

pub contract AthletaverseAthlete: NonFungibleToken {

    // the total supply of Athlete NFTs
    pub var totalSupply: UInt64

    // named paths
    pub let collectionStoragePath: StoragePath
    pub let minterStoragePath: StoragePath

    pub let collectionProviderPath: PrivatePath
    pub let collectionReceiverPath: PrivatePath
    pub let minterPrivatePath: PrivatePath

    pub let collectionPublicPath: PublicPath
    pub let athletePublicPath: PublicPath

    // Events from the NFT standard
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    // Emitted every time a new Athlete is minted
    pub event NewAthleteCreated(id: UInt64, name: String)

    // The Athlete NFT
    pub resource NFT: NonFungibleToken.NFT {

        // the athlete's ID
        pub let id: UInt64

        // the athlete's name
        access(self) let name: String

        init(name: String) {
            
            // get the token ID from the totalSupply
            let tokenID = AthletaverseAthlete.totalSupply

            // set our new Athlete's metadata
            self.id = tokenID
            self.name = name

            // increment the total supply
            AthletaverseAthlete.totalSupply = tokenID + 1 as UInt64

            // emit the event 
            emit NewAthleteCreated(id: tokenID, name: name)
        }

        // returns the Athlete's name to the caller
        pub fun getName(id: UInt64): String {
            return self.name
        }
    }

    pub resource interface AthletePublic {
        // used to borrow a reference to the Athlete NFT
        pub fun borrowAthlete(id: UInt64): &AthletaverseAthlete.NFT
    }

    pub resource Collection: 
        NonFungibleToken.Provider, 
        NonFungibleToken.Receiver, 
        NonFungibleToken.CollectionPublic,
        AthletePublic {

        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
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
            let token <- token as! @ExampleNFT.NFT

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

        // borrowAthlete gets a reference to an Athlete in the
        // collection. The caller can then read and call it's Athlete specific
        // metadata and methods
        pub fun borrowAthlete(id: UInt64): &AthletaverseAthlete.NFT? {
            if self.ownedNFTs[id] != nil {
                let athleteRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return athleteRef as! &AthletaverseAthlete.NFT
            } else {
                return nil
            }
        }

        destroy() {
            destroy ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }


    // AthleteMinter allows the owner of the resource to mint Athlete
    // NFTs
    pub resource AthleteMinter {

		// mintNFT mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
		pub fun mintNFT(name: String, recipient: &NonFungibleToken.Collection{NonFungibleToken.Receiver}) {

			// create a new NFT
			var newNFT <- create NFT(name: name)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-newNFT)
		}
	}

    init() {

        // initialize with zero total supply
        self.totalSupply = 0 as UInt64

        // assign our named paths
        self.collectionStoragePath = /storage/AthletaverseAthleteCollection
        self.minterStoragePath = /storage/AthletaverseAthleteMinter

        self.collectionProviderPath = /private/AthletaverseAthleteCollectionProvider
        self.collectionReceiverPath = /private/AthletaverseAthleteCollectionReceiver
        self.minterPrivatePath = /private/AthletaverseAthleteMinter

        self.collectionPublicPath = /public/AthletaverseAthleteCollection
        self.athletePublicPath = /public/AthletaverseAthletePublicPath

        // create a new athlete minter for the Admin
        self.account.save(<- create AthleteMinter(), to: AthletaverseAthlete.minterStoragePath)

        // link the private path for the Athlete Minter
        self.account.link<&AthleteMinter>(
            AthletaverseAthlete.minterPrivatePath,
            target: AthletaverseAthlete.minterStoragePath
        )

        // create an empty Athlete collection for the admin
        self.account.save(<- create Collection(), to: AthletaverseAthlete.collectionStoragePath)

        // link the private Provider capability
        self.account.link<&{NonFungibleToken.Provider}>(
            AthletaverseAthlete.collectionProviderPath,
            target: AthletaverseAthlete.collectionStoragePath
        )

        // link the private Receiver capability
        self.account.link<&{NonFungibleToken.Receiver}>(
            AthletaverseAthlete.collectionReceiverPath,
            target: AthletaverseAthlete.collectionStoragePath
        )

        // link the CollectionPublic capability
        self.account.link<&{NonFungibleToken.CollectionPublic}>(
            AthletaverseAthlete.collectionPublicPath,
            target: AthletaverseAthlete.collectionStoragePath
        )

        // link the AthletePublic capability
        self.account.link<&{AthletePublic}>(
            AthletaverseAthlete.athletePublicPath,
            target: AthletaverseAthlete.collectionStoragePath
        )
    }

}