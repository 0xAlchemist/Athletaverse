package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"

)

func main() {
	g := gwtf.
		NewGoWithTheFlowEmulator().
		InitializeContracts().
		CreateAccount("user_1", "user_2")

	var ignoreFields = map[string][]string{
		"flow.AccountCodeUpdated": []string{"codeHash"},
		"flow.AccountKeyAdded": []string{"publicKey"},
	}

	// Create a league with user 1
	g.
		TransactionFromFile("league/create_league").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Create a team with user 1
	g.
		TransactionFromFile("team/create_team").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)
	
	// Register the team to the league
	g.
		TransactionFromFile("team/register_team").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Check the team IDs registered to the league
	g.
		ScriptFromFile("league/get_team_ids").
		AccountArgument("user_1").
		Run()

}
