#!/bin/sh
ORIG_PATH=`pwd`
WORK_PATH=`dirname $0`
cd ${WORK_PATH}
STDTEST_DIR="../t"
RUN_CMD="perl -I${WORK_PATH}"
#if [ -e $1 ]; then
#     FILES=$1
#else
    FILES=`ls ${STDTEST_DIR}/*.t  2>/dev/null`
#fi
for test in ${FILES}; do
    echo "--------============Run test for file ${test}========-------"
    ${RUN_CMD} ${test}
#    echo TEST IS ${TEST} FILES is ${FILES}
done
cd ${ORIG_PATH}
exit;    
