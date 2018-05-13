export KALDI_ROOT=/exp/sw/kaldi
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:${KALDI_ROOT}/src/feat:${KALDI_ROOT}/src/util:${KALDI_ROOT}/src/base:${KALDI_ROOT}/src/chain:${KALDI_ROOT}/src/cudamatrix:${KALDI_ROOT}/src/decoder:${KALDI_ROOT}/src/fstext:${KALDI_ROOT}/src/gmm:${KALDI_ROOT}/src/hmm:${KALDI_ROOT}/src/ivector:${KALDI_ROOT}/src/kws:${KALDI_ROOT}/src/lat:${KALDI_ROOT}/src/lm:${KALDI_ROOT}/src/matrix:${KALDI_ROOT}/src/nnet:${KALDI_ROOT}/src/nnet2:${KALDI_ROOT}/src/nnet3:${KALDI_ROOT}/src/online:${KALDI_ROOT}/src/online2:${KALDI_ROOT}/src/online3:${KALDI_ROOT}/src/sgmm2:${KALDI_ROOT}/src/transform:${KALDI_ROOT}/src/tree:${KALDI_ROOT}/src/util
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:${KALDI_ROOT}/tools/openfst/lib
export LC_ALL=C
