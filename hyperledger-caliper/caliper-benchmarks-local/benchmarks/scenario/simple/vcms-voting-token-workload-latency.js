'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class VcmsVotingTokenWorkload extends WorkloadModuleBase {
    constructor() {
        super();
        this.txIndex = 10000;
    }

    async submitTransaction() {
        this.txIndex++;
        
        const vcmsToken = `token_${this.workerIndex}_${this.txIndex}`;
        const vcmsdSignature = `signature_${this.workerIndex}_${this.txIndex}`;

        const startTime = Date.now();

        const args = {
            contractId: 'voting6',
            contractVersion: '1',
            contractFunction: 'VcmsVotingToken',
            contractArguments: [vcmsToken, vcmsdSignature],
            readOnly: false
        };

        try {
            const response = await this.sutAdapter.sendRequests(args);
            const endTime = Date.now();
            const latency = endTime - startTime;

            return {
                'status': 'success',
                'latency': latency,
                'txIndex': this.txIndex
            };
        } catch (error) {
            return {
                'status': 'failed',
                'latency': 0,
                'txIndex': this.txIndex,
                'error': error.toString()
            };
        }
    }
}

function createWorkloadModule() {
    return new VcmsVotingTokenWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;
