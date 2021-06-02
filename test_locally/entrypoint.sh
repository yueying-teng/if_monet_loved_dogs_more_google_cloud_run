#!/usr/bin/env bash
set -e

tensorflow_model_server --rest_api_port=$REST_PORT --model_name=$MODEL_NAME --model_base_path=$MODEL_PATH >> /home/logs/server.log &
streamlit run ui.py --server.port=$PORT >> /home/logs/ui.log &

wait -n