#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"
/misc/local/matlab-2023a/bin/matlab -batch "modpath; compute_z_matches_for_patrick_pipeline('$1', '$2', '$3', '$4', '$5')"
