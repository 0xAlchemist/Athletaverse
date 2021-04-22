// register_team.cdc

// Registers a team to a League

import AthletaverseLeague from 0x01cf0e2f2f715450
import AthletaverseTeam from 0x01cf0e2f2f715450

transaction(leagueOwnerAddress: Address, leagueID: UInt64, teamID: UInt64) {
    prepare(signer: AuthAccount) {

        // get the public account for the league owner
        let leagueOwner = getAccount(leagueOwnerAddress)

        // get the Public capability for the League Collection
        let leagueCollection = leagueOwner.getCapability
            <&AthletaverseLeague.Collection{AthletaverseLeague.CollectionPublic}>
            (AthletaverseLeague.leagueCollectionPublicPath)
            .borrow() ?? panic("account has no League Collection")

        // borrow a reference to the League NFT
        let leagueReference = leagueCollection.borrowLeague(id: leagueID) 
            ?? panic("trying to borrow a league that does not exist")

        // get the public capability for the Team from storage
        let teamPublicCapability = signer.getCapability
            <&{AthletaverseTeam.TeamPublic}>
            (AthletaverseTeam.teamPublicPath)


        if teamPublicCapability.check() == false {
            panic("could not borrow reference to TeamPublic capability")
        }

        // register the Team to the League
        leagueReference.registerTeam(teamCapability: teamPublicCapability)
    }
}