package main

import (
    "encoding/json"
    "fmt"
    // "strings"

    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// VotingContract provides functions for managing voting on channel1
type VotingContract struct {
    contractapi.Contract
}

// BallotRecord represents the structure for storing ballot information on channel1
type BallotRecord struct {
    Ballot      string `json:"ballot"`
    VotingToken string `json:"votingToken"`
    ID          string `json:"id"`
}

// VotingTokenRecord represents the structure for storing voting token information on channel2
type VotingTokenRecord struct {
    VcmsToken string `json:"vcmsToken"`
    ID        string `json:"id"`
}

// CastVote takes voter input and processes it
func (c *VotingContract) CastVote(ctx contractapi.TransactionContextInterface, ballot string, votingToken string) error {
    // Step 1: Verify the voting token on channel2
    votingTokenRecord, err := c.GetVotingTokenFromChannel2(ctx, votingToken)
    if err != nil {
        return fmt.Errorf("failed to verify voting token: %v", err)
    }

    // Step 2: Construct the ID
    fullID := "01" + votingTokenRecord.ID

    // Step 3: Check if the ID already exists in channel1
    exists, err := c.idExistsInChannel1(ctx, fullID)
    if err != nil {
        return err
    }
    if exists {
        return fmt.Errorf("a vote with ID %s has already been cast", fullID)
    }

    // Step 4: Create and store the ballot record
    ballotRecord := BallotRecord{
        Ballot:      ballot,
        VotingToken: votingToken,
        ID:          fullID,
    }

    ballotJSON, err := json.Marshal(ballotRecord)
    if err != nil {
        return fmt.Errorf("failed to marshal ballot record: %v", err)
    }

    err = ctx.GetStub().PutState(fullID, ballotJSON)
    if err != nil {
        return fmt.Errorf("failed to store ballot: %v", err)
    }

    return nil
}

// GetVotingTokenFromChannel2 retrieves and verifies the voting token from channel2
func (c *VotingContract) GetVotingTokenFromChannel2(ctx contractapi.TransactionContextInterface, votingToken string) (*VotingTokenRecord, error) {
    // Retrieve the voting token from channel2
    channel2Stub := ctx.GetStub().InvokeChaincode("voting4", [][]byte{
        []byte("GetVotingTokenRecord"),
        []byte(votingToken),
    }, "mychannel1")

    if channel2Stub.Status != 200 {
        return nil, fmt.Errorf("failed to retrieve voting token from channel2: %s", channel2Stub.Message)
    }

    var record VotingTokenRecord
    err := json.Unmarshal(channel2Stub.Payload, &record)
    if err != nil {
        return nil, fmt.Errorf("failed to unmarshal voting token record: %v", err)
    }

    return &record, nil
}

// idExistsInChannel1 checks if an ID already exists in channel1
func (c *VotingContract) idExistsInChannel1(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    ballotJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return false, fmt.Errorf("failed to read from world state: %v", err)
    }
    return ballotJSON != nil, nil
}

// GetBallot retrieves a ballot by ID
func (c *VotingContract) GetBallot(ctx contractapi.TransactionContextInterface, id string) (*BallotRecord, error) {
    ballotJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return nil, fmt.Errorf("failed to read ballot record: %v", err)
    }
    if ballotJSON == nil {
        return nil, fmt.Errorf("the ballot with ID %s does not exist", id)
    }

    var ballot BallotRecord
    err = json.Unmarshal(ballotJSON, &ballot)
    if err != nil {
        return nil, fmt.Errorf("failed to unmarshal ballot record: %v", err)
    }

    return &ballot, nil
}

func main() {
    chaincode, err := contractapi.NewChaincode(&VotingContract{})
    if err != nil {
        fmt.Printf("Error creating voting chaincode: %v", err)
        return
    }

    if err := chaincode.Start(); err != nil {
        fmt.Printf("Error starting voting chaincode: %v", err)
    }
}