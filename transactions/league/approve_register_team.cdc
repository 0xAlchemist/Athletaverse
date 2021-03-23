// approve_register_team.cdc

// Registers a team to a League

import Athletaverse from 0xf8d6e0586b0a20c7 //0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {

        // borrow a reference to the League from storage
        let leagueReference = signer.borrow<&Athletaverse.League>(from: /storage/AthletaverseLeague)
        ?? panic ("could not borrow league capability")

        // register the Team to the League
        leagueReference.approveRegisterTeam(teamID: UInt64(0))
    }
}