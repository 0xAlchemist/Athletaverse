// EMULATOR ONLY: Mint Flow Test Tokens

// Mints the provided amount of FlowTokens on the
// emulator chain and deposits them into th// recipient's account
//
// This transaction can only be run on the Flow Emulator!

import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

transaction(recipient: PublicAccount, amount: UFix64) {
    let tokenAdmin: &FlowToken.Administrator
    let tokenReceiver: &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        self.tokenAdmin = signer
            .borrow<&FlowToken.Administrator>(from: /storage/flowTokenAdmin)
            ?? panic("Signer is not the token admin")

        self.tokenReceiver = recipient
            .getCapability(/public/flowTokenReceiver)
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Unable to borrow receiver reference")
    }

    execute {
        let minter <- self.tokenAdmin.createNewMinter(allowedAmount: amount)
        let mintedVault <- minter.mintTokens(amount: amount)

        self.tokenReceiver.deposit(from: <-mintedVault)

        destroy minter
    }
}