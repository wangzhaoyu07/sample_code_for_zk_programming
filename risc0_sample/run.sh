#!/bin/bash

# Record the start time
start=$(date +%s)
# Run the baseline
RISC0_DEV_MODE=0 RUST_LOG="[executor]=info" cargo run --release
# Record the end time
end=$(date +%s)
runtime=$((end-start))
echo "Total used time: $runtime seconds"