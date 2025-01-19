import subprocess
import time
import csv
from datetime import datetime

# Environment variables and global settings
CHANNEL_NAME = "mychannel1"
CC_NAME = "voting6"
ORDERER_CA = "${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
PEER0_ORG1_CA = "${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
PEER0_ORG2_CA = "${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"

# def set_globals_for_peer0_org1():
#     os.environ['CORE_PEER_LOCALMSPID'] = "Org1MSP"
#     os.environ['CORE_PEER_TLS_ROOTCERT_FILE'] = os.environ.get('PEER0_ORG1_CA', '')
#     os.environ['CORE_PEER_MSPCONFIGPATH'] = f"{os.getcwd()}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
#     os.environ['CORE_PEER_ADDRESS'] = "localhost:7051"

def invoke_transaction(tx_num):
    start_time = time.time()

    command = f"""
    peer chaincode invoke -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    --tls true \
    --cafile {ORDERER_CA} \
    -C {CHANNEL_NAME} -n {CC_NAME} \
    --peerAddresses localhost:7051 \
    --tlsRootCertFiles {PEER0_ORG1_CA} \
    --peerAddresses localhost:9051 \
    --tlsRootCertFiles {PEER0_ORG2_CA} \
    -c '{{"function": "VcmsVotingToken","Args":["{tx_num}","digitalsignature"]}}'
    """

    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    end_time = time.time()
    latency = (end_time - start_time) * 1000  # Convert to milliseconds

    if process.returncode != 0:
        print(f"Error in transaction {tx_num}: {stderr.decode()}")
        return None

    return latency

def main():
    output_file = "transaction_latency.csv"
    
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Transaction Number", "Latency (ms)", "Timestamp"])

        for i in range(10, 51):
            latency = invoke_transaction(i)
            if latency is not None:
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                writer.writerow([i, f"{latency:.2f}", timestamp])
                print(f"Transaction {i}: Latency = {latency:.2f} ms")
            
    print(f"Transaction latency data has been written to {output_file}")

if __name__ == "__main__":
    main()
