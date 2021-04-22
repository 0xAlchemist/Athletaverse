// create_team.cdc
//
// This transaction creates a new Team and stores it
// in the caller's account
//

import AthletaverseTeam from 0x01cf0e2f2f715450

transaction(teamName: String) {
    prepare(signer: AuthAccount) {
        
        // Get the public TeamMinter capability from the Athletaverse deployer
        let teamMinter = signer.getCapability<&AthletaverseTeam.Minter>
            (AthletaverseTeam.minterPrivatePath)
            .borrow() ?? panic("couldn't borrow public TeamMinter capability")

        // Mint a new team with the provided name
        let team <- teamMinter.createTeam(name: teamName)

        // Save the team to the owner's account storage
        signer.save(<- team, to: AthletaverseTeam.teamStoragePath)

        // Link the public capability
        signer.link<&{AthletaverseTeam.TeamPublic}>(
            AthletaverseTeam.teamPublicPath,
            target: AthletaverseTeam.teamStoragePath
        )

        // Link the private capability
        signer.link<&{AthletaverseTeam.TeamManager}>(
            AthletaverseTeam.teamManagerPath,
            target: AthletaverseTeam.teamStoragePath
        )
    }
}