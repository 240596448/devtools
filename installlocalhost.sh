#!/bin/bash
OSPX_DIR=temp_ospx
mkdir -p $OSPX_DIR
rm -f $OSPX_DIR/*.ospx
opm build -m ./packagedef -o ./$OSPX_DIR/
opm install -f ./$OSPX_DIR/*.ospx
rm $OSPX_DIR/*.ospx
rmdir $OSPX_DIR
echo Installation completed successfully...
