'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

/**
 * Workload module for the benchmark round.
 */
class VcmsVotingTokenWorkload extends WorkloadModuleBase {
    constructor() {
        super();
        this.txIndex = 1001;
    }

    /**
     * Assemble TXs for the round.
     * @return {Promise<TxStatus[]>}
     */
    async submitTransaction() {
        this.txIndex++;
        
        // Generate a unique vcmsToken for each transaction
        const vcmsToken = `token_${this.workerIndex}_${this.txIndex}`;
        
        // Generate a mock signature (in a real scenario, this would be a proper signature)
        const vcmsdSignature = `signature_${this.workerIndex}_${this.txIndex}`;

        let args = {
            contractId: 'voting6',
            contractVersion: '1',
            contractFunction: 'VcmsVotingToken',
            contractArguments: [vcmsToken, vcmsdSignature],
            readOnly: false
        };

        await this.sutAdapter.sendRequests(args);
    }
}

/**
 * Create a new instance of the workload module.
 * @return {WorkloadModuleInterface}
 */
function createWorkloadModule() {
    return new VcmsVotingTokenWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;