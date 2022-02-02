#!/bin/bash
for i in 1 2 3 4; do
 pm2 start ~/.bittensor/bittensor/bittensor/_neuron/text/advanced_server/main.py --name miner00$i --time --interpreter python3 -- --logging.debug --subtensor.network nakamoto --neuron.restart true --server.model_name distilgpt2 --axon.port 8${i}91 --wallet.name bittensor-wallet-`hostname` --wallet.hotkey hotkey$i-`hostname`
done


