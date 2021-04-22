import AthletaverseTeam from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {
        // save the TeamMinter to the signer's account storage
        signer.save(<- AthletaverseTeam.createMinter(), to: AthletaverseTeam.minterStoragePath)

        // link the private capability to the TeamMinter 
        signer.link<&AthletaverseTeam.Minter>(
            AthletaverseTeam.minterPrivatePath, 
            target:AthletaverseTeam.minterStoragePath
        )
    }
}