#define HAVE_CLAPACK 1


#include <unordered_map>
#include <string>
#include <sstream>
#include "util/common-utils.h"



using namespace std;
//for id in $(seq 20); do gunzip -c /home/abhinav/kaldi/accents/exp/tri4_cv_train_nz_ali_sp/ali.$id.gz; done | ali-to-pdf /home/abhinav/kaldi/accents/exp/tri4_cv_train_nz_ali_sp/final.mdl ark:- ark,t:ali.scp
//ali-to-pdf /home/abhinav/kaldi/accents/exp/tri4_cv_train_nz_ali_sp/final.mdl ark:- ark,t:ali.scp


/*
export LD_LIBRARY_PATH=/usr/lib/atlas-base:/exp/sw/kaldi/src/lib:/exp/sw/kaldi/tools/openfst-1.6.2/src/lib/.libs:$LD_LIBRARY_PATH

Compile on Linux
g++ --std=c++11 -I/exp/sw/kaldi/tools/openfst-1.6.2/src/include -I/exp/sw/kaldi/src -I/exp/sw/kaldi/tools/CLAPACK/ -g -O3 temp.cc -o ./temp /exp/sw/kaldi/tools/openfst-1.6.2/src/lib/.libs/libfst.so* /exp/sw/kaldi/src/lib/*.so -ldl -lpthread



When 3 args
./temp cv-train-sp-accents ali.scp "ark:|gzip -c > ali.1.gz"

./temp cv-train-sp-accents ali.scp "ark,t:ali.1"

run.pl JOB=1:20 test/log/temp.JOB.log ./temp test/acc/xJOB test/ali/xJOB ark,t:test/out/JOB.scp
|gzip -c >$dir/ali.1.gz"

*/



void ReadSpaceSeparatedFile(const char* accent_file, std::unordered_map<string, string>& m)
{ 
  std::string line;
  std::ifstream myFile(accent_file);
  if(myFile.is_open())
  {
    while(getline(myFile, line))
    {
      std::string uttId;
      std::string delimiter=" ";
      int pos;
      pos=line.find(delimiter);
      uttId=line.substr(0,pos);
      line.erase(0,pos+delimiter.length());
      m.insert(make_pair(uttId, line));
    }
  }

}


int main(int argc, char *argv[]) {

    using namespace kaldi;
    typedef kaldi::int32 int32;

    const char *usage =
        "Align features given [GMM-based] models.\n"
        "Usage:   gmm-align-compiled [options] <model-in> <graphs-rspecifier> "
        "<feature-rspecifier> <alignments-wspecifier> [scores-wspecifier]\n"
        "e.g.: \n"
        " gmm-align-compiled 1.mdl ark:graphs.fsts scp:train.scp ark:1.ali\n"
        "or:\n"
        " compile-train-graphs tree 1.mdl lex.fst 'ark:sym2int.pl -f 2- words.txt text|' \\\n"
        "   ark:- | gmm-align-compiled 1.mdl ark:- scp:train.scp t, ark:1.ali\n";

    ParseOptions po(usage);
    po.Read(argc, argv);

    if (po.NumArgs() != 3) {
      po.PrintUsage();
      exit(1);
    }

    std::string accents_file_rspecifier = po.GetArg(1),
    	align_file_rspecifier = po.GetArg(2),
        alignment_wspecifier = po.GetArg(3);

    Int32VectorWriter alignment_writer(alignment_wspecifier);

    const char* file_str1=accents_file_rspecifier.c_str();
    unordered_map<string, string> uttToAccent;
    ReadSpaceSeparatedFile(file_str1, uttToAccent);
    cout << "Size of uttToAccent:" << uttToAccent.size()<<endl;

    const char* file_str2=align_file_rspecifier.c_str();
    unordered_map<string, string> uttToAlign;
    ReadSpaceSeparatedFile(file_str2, uttToAlign);
    cout << "Size of uttToAlign:" << uttToAlign.size()<<endl;
    getchar();
    int count =0;
    int32 notfound=0;
    for (unordered_map<string, string>::iterator it=uttToAlign.begin();
    		it!=uttToAlign.end(); ++it) 
    {
      //count++;
      //cout<<count<<endl;
      std::string uttId = it->first;
      //cout<<it->first<<endl;
      int32 accent = stoi(uttToAccent[it->first]);
      
    	//cout << uttId << std::endl;
      string align=it->second;
      string delimiter=" ";
      int pos;
      std::vector<int32> temp;
      while((pos=align.find(delimiter))!=string::npos)
      {
        temp.push_back(accent);
        align.erase(0,pos+delimiter.length());
      }
      
      //cout << "Size of alignment:" << temp.size() << endl;
      alignment_writer.Write(uttId, temp);
}
  
}