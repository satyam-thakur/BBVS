'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

/**
 * Workload module for benchmarking the CastVote function.
 */
class CastVoteWorkload extends WorkloadModuleBase {
    constructor() {
        super();
        this.txIndex = 0;
    }

    /**
     * Initialize the workload module with the given parameters.
     * @param {number} workerIndex The 0-based index of the worker instantiating the workload module.
     * @param {number} totalWorkers The total number of workers participating in the round.
     * @param {number} roundIndex The 0-based index of the currently executing round.
     * @param {Object} roundArguments The user-provided arguments for the round from the benchmark configuration file.
     * @param {ConnectorBase} sutAdapter The adapter of the underlying SUT.
     * @param {Object} sutContext The custom context object provided by the SUT adapter.
     * @async
     */
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
    }

    /**
     * Assemble TXs for the round.
     * @return {Promise<TxStatus>}
     */
    async submitTransaction() {
        this.txIndex++;
        
        // Generate a unique ballot for each transaction
        const ballot = `ballot_${this.workerIndex}_${this.txIndex}`;

        // Use the same token format as in VcmsVotingTokenWorkload
        const votingTokenHash = `token_${this.workerIndex}_${this.txIndex}`;

        let args = {
            contractId: 'voting8',
            contractVersion: '1',
            contractFunction: 'CastVote',
            contractArguments: [ballot, votingTokenHash],
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
    return new CastVoteWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;