// create_leagues.cdc
//
// This transaction creates a new League and stores it
// in the caller's account
//

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseLeague from 0x01cf0e2f2f715450

transaction(minterAddress: Address) {

    prepare(signer: AuthAccount) {

        let minterAccount = getAccount(minterAddress)
        
        let lockedMinter = minterAccount.getCapability
            <&AthletaverseLeague.LeagueMinter{AthletaverseLeague.LockedLeagueMinter}>
            (AthletaverseLeague.lockedLeagueMinterPublicPath)
            .borrow() ?? panic("could not borrow a reference to the LockedLeagueMinter")

        let approvedMinter = signer.getCapability
            <&AthletaverseLeague.LeagueSuperAdmin{AthletaverseLeague.ApprovedLeagueMinter}>
            (AthletaverseLeague.approvedLeagueMinterPrivatePath)

        lockedMinter.addLeagueMintingCapability(approvedMinter)
    }
}