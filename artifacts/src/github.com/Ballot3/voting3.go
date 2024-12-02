package main

import (
    "crypto/sha256"
    "encoding/hex"
    "encoding/json"
    "fmt"

    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// VotingContract provides functions for managing voting tokens
type VotingContract struct {
    contractapi.Contract
}

// VotingTokenRecord represents the structure for storing voting token information
type VotingTokenRecord struct {
    VcmsToken string `json:"vcmsToken"`
    ID        string `json:"id"`
    Verified  bool   `json:"verified"`
}

// VcmsVotingToken stores the received hash
func (c *VotingContract) VcmsVotingToken(ctx contractapi.TransactionContextInterface, vcmsToken string) error {
    exists, err := c.TokenExists(ctx, vcmsToken)
    if err != nil {
        return err
    }
    if exists {
        return fmt.Errorf("the voting token %s already exists", vcmsToken)
    }

    record := VotingTokenRecord{
        VcmsToken: vcmsToken,
        ID:        "",
        // Verified:  false,
    }

    recordJSON, err := json.Marshal(record)
    if err != nil {
        return fmt.Errorf("failed to marshal voting token record: %v", err)
    }

    err = ctx.GetStub().PutState(vcmsToken, recordJSON)
    if err != nil {
        return fmt.Errorf("failed to store voting token: %v", err)
    }

    return nil
}

// VoteCheck retrieves the VCMS hash and verifies the voting token
func (c *VotingContract) VoteCheck(ctx contractapi.TransactionContextInterface, vcmsToken string) (string, error) {
    record, err := c.getVotingTokenRecord(ctx, vcmsToken)
    if err != nil {
        return "", err
    }

    // Case 1: Voting token exists, is verified, and has an ID (duplicate case)
    if record.Verified && record.ID != "" {
        return "", fmt.Errorf("duplicate hash detected: %s", vcmsToken)
    }

    // Case 2: Voting token exists, is not verified, and has no ID (eligible case)
    if !record.Verified && record.ID == "" {
        // Set the token as verified
        record.Verified = true

        // Generate deterministic key and set it as ID
        deterministicKey, err := c.GenerateDeterministicKey(ctx, vcmsToken)
        if err != nil {
            return "", err
        }
        record.ID = deterministicKey

        // Update the record in the world state
        recordJSON, err := json.Marshal(record)
        if err != nil {
            return "", fmt.Errorf("failed to marshal updated voting token record: %v", err)
        }
        err = ctx.GetStub().PutState(vcmsToken, recordJSON)
        if err != nil {
            return "", fmt.Errorf("failed to update voting token: %v", err)
        }

        return deterministicKey, nil
    }

    // If we reach here, it means the record is in an unexpected state
    return "", fmt.Errorf("voting token %s is in an invalid state", vcmsToken)
}

// SetVerified sets the Verified flag to true for a voting token
func (c *VotingContract) SetVerified(ctx contractapi.TransactionContextInterface, vcmsToken string) error {
    record, err := c.getVotingTokenRecord(ctx, vcmsToken)
    if err != nil {
        return err
    }

    record.Verified = true

    recordJSON, err := json.Marshal(record)
    if err != nil {
        return fmt.Errorf("failed to marshal updated voting token record: %v", err)
    }

    err = ctx.GetStub().PutState(vcmsToken, recordJSON)
    if err != nil {
        return fmt.Errorf("failed to update voting token: %v", err)
    }

    return nil
}

// GenerateDeterministicKey generates a deterministic key and appends it to the ID field
func (c *VotingContract) GenerateDeterministicKey(ctx contractapi.TransactionContextInterface, vcmsToken string) (string, error) {
    txID := ctx.GetStub().GetTxID()
    data := txID + vcmsToken

    hash := sha256.Sum256([]byte(data))
    deterministicKey := hex.EncodeToString(hash[:])[:3]

    record, err := c.getVotingTokenRecord(ctx, vcmsToken)
    if err != nil {
        return "", err
    }

    record.ID = deterministicKey

    recordJSON, err := json.Marshal(record)
    if err != nil {
        return "", fmt.Errorf("failed to marshal updated voting token record: %v", err)
    }

    err = ctx.GetStub().PutState(vcmsToken, recordJSON)
    if err != nil {
        return "", fmt.Errorf("failed to update voting token: %v", err)
    }

    return deterministicKey, nil
}

// TokenExists checks if a token exists
func (c *VotingContract) TokenExists(ctx contractapi.TransactionContextInterface, vcmsToken string) (bool, error) {
    recordJSON, err := ctx.GetStub().GetState(vcmsToken)
    if err != nil {
        return false, fmt.Errorf("failed to read from world state: %v", err)
    }
    return recordJSON != nil, nil
}

// getVotingTokenRecord retrieves a voting token record
func (c *VotingContract) getVotingTokenRecord(ctx contractapi.TransactionContextInterface, vcmsToken string) (*VotingTokenRecord, error) {
    recordJSON, err := ctx.GetStub().GetState(vcmsToken)
    if err != nil {
        return nil, fmt.Errorf("failed to read voting token record: %v", err)
    }
    if recordJSON == nil {
        return nil, fmt.Errorf("the voting token %s does not exist", vcmsToken)
    }

    var record VotingTokenRecord
    err = json.Unmarshal(recordJSON, &record)
    if err != nil {
        return nil, fmt.Errorf("failed to unmarshal voting token record: %v", err)
    }

    return &record, nil
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