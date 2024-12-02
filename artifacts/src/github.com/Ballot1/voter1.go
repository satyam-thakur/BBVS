package main

import (
    "crypto/rand"
    "encoding/hex"
    "encoding/json"
    "fmt"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing the voting process
type SmartContract struct {
    contractapi.Contract
}

// VCMSHash represents a hash from the Voter Credential Management System
type VCMSHash struct {
    Hash string `json:"hash"`
}

// Ballot represents a voter's ballot
type Ballot struct {
    VoteChoice string `json:"voteChoice"`
    VCMSHash   string `json:"vcmsHash"`
}

// VotingToken represents a token used for voting
type VotingToken struct {
    Token string `json:"token"`
}

// generateRandomHex generates a random hex string of length 3
func generateRandomHex() (string, error) {
    bytes := make([]byte, 2)
    if _, err := rand.Read(bytes); err != nil {
        return "", err
    }
    return hex.EncodeToString(bytes)[:3], nil
}

// getOrCreateVoterHex gets an existing hex for a voter or creates a new one
func (s *SmartContract) getOrCreateVoterHex(ctx contractapi.TransactionContextInterface, voterID string) (string, error) {
    voterHexKey := fmt.Sprintf("VOTERHEX_%s", voterID)
    voterHexBytes, err := ctx.GetStub().GetState(voterHexKey)
    if err != nil {
        return "", fmt.Errorf("failed to read voter hex from world state: %v", err)
    }

    var voterHex string
    if voterHexBytes == nil {
        // Generate new hex if it doesn't exist
        voterHex, err = generateRandomHex()
        if err != nil {
            return "", err
        }
        // Store the hex for future use
        err = ctx.GetStub().PutState(voterHexKey, []byte(voterHex))
        if err != nil {
            return "", fmt.Errorf("failed to store voter hex: %v", err)
        }
    } else {
        voterHex = string(voterHexBytes)
    }

    return voterHex, nil
}

// generateKey generates a key with the specified prefix and the voter's consistent hex
func (s *SmartContract) generateKey(ctx contractapi.TransactionContextInterface, prefix string, voterID string) (string, error) {
    voterHex, err := s.getOrCreateVoterHex(ctx, voterID)
    if err != nil {
        return "", err
    }
    return fmt.Sprintf("%s%s", prefix, voterHex), nil
}

// StoreVCMSHash stores a hash value from VCMS
func (s *SmartContract) StoreVCMSHash(ctx contractapi.TransactionContextInterface, voterID string, vcmsHash string) (string, error) {
    vcmsHashKey, err := s.generateKey(ctx, "000", voterID)
    if err != nil {
        return "", err
    }

    exists, err := s.AssetExists(ctx, vcmsHashKey)
    if err != nil {
        return "", err
    }
    if exists {
        return "", fmt.Errorf("a VCMS hash for this voter already exists")
    }

    vcmsHashAsset := VCMSHash{
        Hash: vcmsHash,
    }
    vcmsHashJSON, err := json.Marshal(vcmsHashAsset)
    if err != nil {
        return "", err
    }

    err = ctx.GetStub().PutState(vcmsHashKey, vcmsHashJSON)
    if err != nil {
        return "", err
    }

    return vcmsHashKey, nil
}

// SubmitBallot allows a voter to submit their ballot
func (s *SmartContract) SubmitBallot(ctx contractapi.TransactionContextInterface, voterID string, voteChoice string, vcmsHash string) (string, error) {
    vcmsHashKey, err := s.generateKey(ctx, "000", voterID)
    if err != nil {
        return "", err
    }

    vcmsHashJSON, err := ctx.GetStub().GetState(vcmsHashKey)
    if err != nil {
        return "", fmt.Errorf("failed to read VCMS hash from world state: %v", err)
    }
    if vcmsHashJSON == nil {
        return "", fmt.Errorf("the VCMS hash for this voter does not exist")
    }

    var storedVCMSHash VCMSHash
    err = json.Unmarshal(vcmsHashJSON, &storedVCMSHash)
    if err != nil {
        return "", err
    }

    if vcmsHash != storedVCMSHash.Hash {
        return "", fmt.Errorf("provided VCMS hash does not match the stored hash")
    }

    ballotKey, err := s.generateKey(ctx, "222", voterID)
    if err != nil {
        return "", err
    }

    exists, err := s.AssetExists(ctx, ballotKey)
    if err != nil {
        return "", err
    }
    if exists {
        return "", fmt.Errorf("a ballot for this voter already exists")
    }

    ballot := Ballot{
        VoteChoice: voteChoice,
        VCMSHash:   vcmsHash,
    }
    ballotJSON, err := json.Marshal(ballot)
    if err != nil {
        return "", err
    }

    err = ctx.GetStub().PutState(ballotKey, ballotJSON)
    if err != nil {
        return "", err
    }

    return ballotKey, nil
}

// StoreVotingToken stores a voting token after the voting phase is complete
func (s *SmartContract) StoreVotingToken(ctx contractapi.TransactionContextInterface, voterID string, token string) (string, error) {
    tokenKey, err := s.generateKey(ctx, "111", voterID)
    if err != nil {
        return "", err
    }

    exists, err := s.AssetExists(ctx, tokenKey)
    if err != nil {
        return "", err
    }
    if exists {
        return "", fmt.Errorf("a voting token for this voter already exists")
    }

    votingToken := VotingToken{
        Token: token,
    }
    tokenJSON, err := json.Marshal(votingToken)
    if err != nil {
        return "", err
    }

    err = ctx.GetStub().PutState(tokenKey, tokenJSON)
    if err != nil {
        return "", err
    }

    return tokenKey, nil
}

// GetBallot retrieves a ballot for a given ballot key
func (s *SmartContract) GetBallot(ctx contractapi.TransactionContextInterface, ballotKey string) (*Ballot, error) {
    ballotJSON, err := ctx.GetStub().GetState(ballotKey)
    if err != nil {
        return nil, fmt.Errorf("failed to read ballot from world state: %v", err)
    }
    if ballotJSON == nil {
        return nil, fmt.Errorf("the ballot for this key does not exist")
    }

    var ballot Ballot
    err = json.Unmarshal(ballotJSON, &ballot)
    if err != nil {
        return nil, err
    }

    return &ballot, nil
}

// AssetExists returns true when asset with given ID exists in world state
func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    assetJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return false, fmt.Errorf("failed to read from world state: %v", err)
    }

    return assetJSON != nil, nil
}

func main() {
    chaincode, err := contractapi.NewChaincode(new(SmartContract))
    if err != nil {
        fmt.Printf("Error creating voting chaincode: %v", err)
        return
    }

    if err := chaincode.Start(); err != nil {
        fmt.Printf("Error starting voting chaincode: %v", err)
    }
}