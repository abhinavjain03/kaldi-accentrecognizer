. ./cmd.sh
. ./path.sh

nj=30
bnf_dim=1024
modelDirectory=/exp/abhinav/accents_exp
#trainSet=cv_train_with_accents_except_indian
#trainSet=cv_train_all_nz_with_accents
#trainSet=cv_train_with_accents_except_england_canada
#trainSet=cv_train_with_accents_except_newzealand+adaptonlynz
trainSet="cv_train_nz_15000_with_accents"
decodeSet=cv_dev_nz_with_accents
affix=
train_stage=-10
num_targets=7

. utils/parse_options.sh


dir=exp/nnet3/tdnn_${affix}


mfcc=0
mfcchires=0
alignData=0
getAccentAligns=0
config=0
egsTrain=0
train=1
computeOutput=0



mfccdir=exp/mfcc
if [ $mfcc -eq 1 ]; then
	for x in $trainSet; do
		steps/make_mfcc.sh --nj $nj --mfcc-config conf/mfcc_16k.conf --cmd "$train_cmd" \
				data/$x exp/make_mfcc/$x $mfccdir
		steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
		utils/fix_data_dir.sh data/$x
	done
fi

mfccdir=exp/mfcc_hires
if [ $mfcchires -eq 1 ]; then
  for x in $trainSet; do
    utils/copy_data_dir.sh data/$x data/${x}_hires
    steps/make_mfcc.sh --nj $nj --mfcc-config conf/mfcc_hires_16k.conf --cmd "$train_cmd" \
        data/${x}_hires exp/make_hires/$x $mfccdir;
    steps/compute_cmvn_stats.sh data/${x}_hires exp/make_hires/${x} $mfccdir;
    utils/fix_data_dir.sh data/${x}_hires
  done
fi

dataalidir=exp/tri4_${trainSet}_ali
if [ $alignData -eq 1 ]; then

    steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" \
             data/$trainSet data/lang $modelDirectory/tri4 $dataalidir

fi

##After aligning the data merge all the alignments into one file,
##and generate accent posteriors
#accentalidir=exp/tri4_train_with_accents_except_indian_ali
#accentalidir=exp/tri4_train_all_nz_with_accents_ali
accentalidir=exp/tri4_accents_${trainSet}_ali
if [ $getAccentAligns -eq 1 ]; then

    mkdir test
    mkdir $accentalidir
    for id in $(seq $nj); do gunzip -c $dataalidir/ali.$id.gz; done | ali-to-pdf $dataalidir/final.mdl ark:- ark,t:test/ali.scp
    export LD_LIBRARY_PATH=/usr/lib/atlas-base:/exp/sw/kaldi/src/lib:/exp/sw/kaldi/tools/openfst-1.6.2/src/lib/.libs:$LD_LIBRARY_PATH
    ./temp data/$trainSet/accent_num test/ali.scp "ark:|gzip -c > $accentalidir/ali.1.gz"
    echo "1" > $accentalidir/num_jobs
    cp $dataalidir/final.mdl $accentalidir
    cp $dataalidir/tree $accentalidir

fi


if [ $config -eq 1 ]; then

  mkdir -p $dir/configs

  cat <<EOF > $dir/configs/network.xconfig
  input dim=40 name=input

  # please note that it is important to have input layer with the name=input
  # as the layer immediately preceding the fixed-affine-layer to enable
  # the use of short notation for the descriptor
  # the first splicing is moved before the lda layer, so no splicing here
  relu-renorm-layer name=tdnn1 input=Append(-2,-1,0,1,2) dim=1024
  relu-renorm-layer name=tdnn2 dim=1024
  relu-renorm-layer name=tdnn3 input=Append(-1,2) dim=1024
  relu-renorm-layer name=tdnn4 input=Append(-3,3) dim=1024
  relu-renorm-layer name=tdnn5 input=Append(-3,3) dim=1024
  relu-renorm-layer name=tdnn6 input=Append(-7,2) dim=1024
  relu-renorm-layer name=tdnn_bn dim=$bnf_dim

  relu-renorm-layer name=prefinal-affine-1 input=tdnn_bn dim=1024
  output-layer name=output dim=${num_targets} max-change=1.5
EOF
  steps/nnet3/xconfig_to_configs.py --xconfig-file $dir/configs/network.xconfig --config-dir $dir/configs/

fi



if [ $egsTrain -eq 1 ]; then
  cmd=run.pl
  left_context=16
  right_context=12

  context_opts="--left-context=$left_context --right-context=$right_context"

    transform_dir=${accentalidir}
    cmvn_opts="--norm-means=false --norm-vars=false"
    extra_opts=()
    extra_opts+=(--cmvn-opts "$cmvn_opts")
    extra_opts+=(--left-context $left_context)
    extra_opts+=(--right-context $right_context)
    echo "$0: calling get_egs.sh for generating examples with alignments as output"


  steps/nnet3/get_egs_mod.sh $egs_opts "${extra_opts[@]}" \
    --num-utts-subset 300 \
    --nj $nj \
    --num-pdfs ${num_targets} \
      --samples-per-iter 200000 \
      --cmd "$cmd" \
      --frames-per-eg 8 \
      data/${trainSet}_hires ${accentalidir} $dir/egs || exit 1;

fi

# if [ $egsDecode -eq 1 ]; then
#   cmd=run.pl
#   left_context=16
#   right_context=12

#   context_opts="--left-context=$left_context --right-context=$right_context"

#     transform_dir=${accentalidir}
#     cmvn_opts="--norm-means=false --norm-vars=false"
#     extra_opts=()
#     extra_opts+=(--cmvn-opts "$cmvn_opts")
#     extra_opts+=(--left-context $left_context)
#     extra_opts+=(--right-context $right_context)
#     echo "$0: calling get_egs.sh for generating examples with alignments as output"


#   steps/nnet3/get_egs_mod.sh $egs_opts "${extra_opts[@]}" \
#     --num-utts-subset 300 \
#     --nj $nj \
#     --num-pdfs ${num_targets} \
#       --samples-per-iter 400000 \
#       --cmd "$cmd" \
#       --frames-per-eg 8 \
#       data/${trainSet}_hires ${accentalidir} $dir/egs || exit 1;

# fi


if [ $train -eq 1 ]; then

  steps/nnet3/train_raw_dnn.py --stage=$train_stage \
    --cmd="$decode_cmd" \
    --feat.cmvn-opts="--norm-means=false --norm-vars=false" \
    --trainer.num-epochs 2 \
    --trainer.optimization.num-jobs-initial 3 \
    --trainer.optimization.num-jobs-final 4 \
    --trainer.optimization.initial-effective-lrate 0.0017 \
    --trainer.optimization.final-effective-lrate 0.00017 \
    --egs.dir $dir/egs \
    --cleanup.preserve-model-interval 20 \
    --use-gpu true \
    --use-dense-targets false \
    --feat-dir=data/${trainSet}_hires \
    --reporting.email="$reporting_email" \
    --dir $dir  || exit 1;

fi

if [ $computeOutput -eq 1 ]; then
    steps/nnet3/compute_output.sh --nj $nj \
        --use-gpu true \
        --extra-left-context 16 \
        --extra-right-context 12 \
        --apply-exp true \
        data/${decodeSet}_hires $dir $dir/output_${decodeSet}
fi
