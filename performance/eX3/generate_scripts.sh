#!/bin/bash
export OUT_DIR=_out
rm -rf $OUT_DIR
mkdir -p $OUT_DIR
HEADER=true
while IFS=$'\t' read -r -a arch
do
 if $HEADER; then
  HEADER=false
  continue
 fi
 export ARCH_NAME=${arch[0]}
 export ARCH_QUEUE=${arch[1]}
 export ARCH_NUM_NODES=${arch[2]}
 export ARCH_NUM_CORES=${arch[3]}
 export ARCH_BINARY=${arch[4]}
 export ARCH_CONFIGS=${arch[5]}
 echo "arch=$ARCH_NAME, queue=$ARCH_QUEUE, nodes=$ARCH_NUM_NODES, cores=$ARCH_NUM_CORES, binary=$ARCH_BINARY, configs=$ARCH_CONFIGS"
 IFS='|' read -ra confs <<< "$ARCH_CONFIGS"
 for conf in "${confs[@]}"; do
  IFS=':' read -ra conf_fields <<< "$conf"
  export ARCH_CONFIG_NAME=${conf_fields[0]}
  export ARCH_CONFIG_CORES=${conf_fields[1]}
  echo "  config_name=$ARCH_CONFIG_NAME: config_cores=$ARCH_CONFIG_CORES"
  envsubst '$ARCH_NAME $ARCH_QUEUE $ARCH_NUM_NODES $ARCH_NUM_CORES $ARCH_BINARY $ARCH_CONFIG_NAME $ARCH_CONFIG_CORES' <script_templ >$OUT_DIR/run_${ARCH_NAME}_${ARCH_CONFIG_NAME}
  chmod +x $OUT_DIR/run_${ARCH_NAME}_${ARCH_CONFIG_NAME}
  echo "sbatch run_${ARCH_NAME}_${ARCH_CONFIG_NAME}" >>$OUT_DIR/run_all.sh
 done
done < arch_def
chmod +x $OUT_DIR/run_all.sh
cp -rf src $OUT_DIR
