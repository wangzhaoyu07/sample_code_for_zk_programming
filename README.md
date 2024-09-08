# Sample Codes for ZK Programming

This repository contains simple examples demonstrating how to write ZK programs in RISC0 and Circom. It focuses on implementing the inference of the [Double Machine Learning (DML)](https://matheusfacure.github.io/python-causality-handbook/22-Debiased-Orthogonal-Machine-Learning.html) model using a basic linear regression model.

## Sample code for RISC0

### Usage

1. Installation:

    To install RISC0, refer to the instructions on the [RISC0 homepage](https://dev.risczero.com/api/zkvm/install).

2. Run the code:
    
    ```bash
    cd risc0_sample
    bash run.sh
    ```

## Sample code for Circom

### Usage

1. Installation:

    Follow the instructions on the [Circom homepage](https://docs.circom.io/getting-started/installation/#installing-circom) to install Circom.

    Next, install [circomlib](https://github.com/iden3/circomlib) by executing:

    ```bash
    npm i circomlib
    ```
2. Run the code:

    ```bash
    cd circom_sample
    bash run_baseline.sh
    ```

    There is one modification required in the `run_baseline.sh` script. You need to replace the part after `-l` in line 7 with the path to the `node_modules` directory on your local machine.

    Note that Circom does not support floating-point numbers. The code uses integers as inputs to illustrate the fundamental process of writing a ZK program in Circom.

    

