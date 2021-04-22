import NonFungibleToken from 0xf8d6e0586b0a20c7
import AthletaverseTeam from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {

        // save the Team Collection to the signer's account storage
        signer.save(
            <- AthletaverseTeam.createEmptyCollection(),
            to: AthletaverseTeam.collectionStoragePath
        )

        // link the private capability to the Collection Manager 
        signer.link<&{AthletaverseTeam.Manager}>(
            AthletaverseTeam.managerPrivatePath, 
            target: AthletaverseTeam.collectionStoragePath
        )

        // link the public Registration capability
        signer.link<&{AthletaverseTeam.Registration}>(
            AthletaverseTeam.registrationPublicPath, 
            target: AthletaverseTeam.collectionStoragePath
        )

        // link the private capability to the Collection Provider 
        signer.link<&{NonFungibleToken.Provider}>(
            AthletaverseTeam.collectionProviderPrivatePath, 
            target: AthletaverseTeam.collectionStoragePath
        )

        // link the private capability to the Collection Receiver 
        signer.link<&{NonFungibleToken.Receiver}>(
            AthletaverseTeam.collectionReceiverPrivatePath, 
            target: AthletaverseTeam.collectionStoragePath
        )

        // link the CollectionPublic capability
        signer.link<&{NonFungibleToken.CollectionPublic}>(
            AthletaverseTeam.collectionPublicPath, 
            target: AthletaverseTeam.collectionStoragePath
        )
    }
}