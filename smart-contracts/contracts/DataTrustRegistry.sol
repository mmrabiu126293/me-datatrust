// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title DataTrustRegistry
/// @notice Registers dataset and quality-report fingerprints so anyone can
///         later check whether a file has changed. Datasets are never stored on-chain.
contract DataTrustRegistry {
    struct Record {
        bytes32 datasetHash; // SHA-256 of the dataset file
        bytes32 reportHash;  // SHA-256 of the AI quality report
        address owner;       // wallet that registered it
        uint256 timestamp;   // block time of registration
    }

    mapping(bytes32 => Record) private records;

    event DatasetRegistered(
        bytes32 indexed datasetId,
        bytes32 datasetHash,
        bytes32 reportHash,
        address indexed owner,
        uint256 timestamp
    );

    error AlreadyRegistered(bytes32 datasetId);
    error NotRegistered(bytes32 datasetId);

    function registerDataset(
        bytes32 datasetId,
        bytes32 datasetHash,
        bytes32 reportHash
    ) external {
        if (records[datasetId].timestamp != 0) revert AlreadyRegistered(datasetId);

        records[datasetId] = Record({
            datasetHash: datasetHash,
            reportHash: reportHash,
            owner: msg.sender,
            timestamp: block.timestamp
        });

        emit DatasetRegistered(datasetId, datasetHash, reportHash, msg.sender, block.timestamp);
    }

    function isRegistered(bytes32 datasetId) external view returns (bool) {
        return records[datasetId].timestamp != 0;
    }

    function verifyDataset(bytes32 datasetId, bytes32 submittedHash) external view returns (bool) {
        Record memory r = records[datasetId];
        if (r.timestamp == 0) revert NotRegistered(datasetId);
        return r.datasetHash == submittedHash;
    }

    function verifyReport(bytes32 datasetId, bytes32 submittedHash) external view returns (bool) {
        Record memory r = records[datasetId];
        if (r.timestamp == 0) revert NotRegistered(datasetId);
        return r.reportHash == submittedHash;
    }

    function getDataset(bytes32 datasetId) external view returns (Record memory) {
        Record memory r = records[datasetId];
        if (r.timestamp == 0) revert NotRegistered(datasetId);
        return r;
    }
}