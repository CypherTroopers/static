#!/bin/bash
./build/bin/cypher \
 --verbosity 4 \
 --rnetport 7100 \
 --syncmode full \
 --nat extip:$(curl -4 -s ifconfig.io) \
 --ws \
 --ws.addr 0.0.0.0 \
 --ws.port 8546 \
 --ws.origins "*" \
 --metrics \
 --http \
 --http.addr 0.0.0.0 \
 --http.port 8000 \
 --http.api eth,web3,net,txpool \
 --http.corsdomain "*" \
 --port 6000 \
 --datadir chaindb/0 \
 --config ./static-nodes.toml \
 --networkid 16166 \
 --gcmode archive \
 --bootnodes enode://c5ed3acb7cd3a7f0fc5f05f9f9fa717c5abee4ee661cfb58b2e85a23bf9f52400a072cb1670b708439bd9a4e3448222904adb7f9dddf860de1bfb1dded100b95@104.196.71.104:6000 \
 console
