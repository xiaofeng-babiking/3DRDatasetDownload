#!/bin/sh

# Skip files that are already complete; resume partial ones.
# A file is written to <name>.part first and renamed only after wget succeeds,
# so an existing <name> means it finished downloading.
# Re-run the script after an interruption to continue where it stopped.
fetch() {
  out="$1"
  url="$2"
  if [ -f "$out" ]; then
    echo "[skip] $out already exists"
    return 0
  fi
  if wget -v -c -O "$out.part" -L "$url"; then
    mv "$out.part" "$out"
  else
    echo "[fail] $out (partial data kept in $out.part, re-run to resume)" >&2
    FAILED=1
  fi
}
FAILED=0

# Download the training set
# RGB frame
# Download multiple files at a time to speed up.
fetch sailvos_train.tar.001 https://uofi.box.com/shared/static/98e10vflopc6z6w70h6me1acv0aqn4yt.001
fetch sailvos_train.tar.002 https://uofi.box.com/shared/static/yrzhc8m1gbz8nkc4eiw33ucz5mck5bbc.002
fetch sailvos_train.tar.003 https://uofi.box.com/shared/static/u4bhab5yio7shmdewvooilrpzq9hpr6j.003
fetch sailvos_train.tar.004 https://uofi.box.com/shared/static/16hnffnx10a1j8fnwddyscz7mjykrram.004
fetch sailvos_train.tar.005 https://uofi.box.com/shared/static/b6kyggl2qke5gpusncg7d4727w2kodrd.005
fetch sailvos_train.tar.006 https://uofi.box.com/shared/static/da32234yojvzd0h3h5uvsgyczyj14e79.006
fetch sailvos_train.tar.007 https://uofi.box.com/shared/static/hfnmbhbwsz7vix48yxl56xwhisqfp2mh.007
fetch sailvos_train.tar.008 https://uofi.box.com/shared/static/c2zy7k4bthtt09ty8z1uyyofwbx5512a.008
fetch sailvos_train.tar.009 https://uofi.box.com/shared/static/omwdysb4nh5n4yem21s4pmbqfib0st3s.009
fetch sailvos_train.tar.010 https://uofi.box.com/shared/static/vgunuka03mql6p1ihibb5zd80mhd8ayx.010
fetch sailvos_train.tar.011 https://uofi.box.com/shared/static/9g3yo3kn6ic4p26bb108cdved1nbvjgz.011
fetch sailvos_train.tar.012 https://uofi.box.com/shared/static/ii9z8pww8v50d14nrh5ifksahwksfhn4.012
fetch sailvos_train.tar.013 https://uofi.box.com/shared/static/08bcxx3ew59dpuerzx68by59ia02ag29.013
fetch sailvos_train.tar.014 https://uofi.box.com/shared/static/m7ikjt28pdskbh05x6v8hsrtyptv3enj.014
fetch sailvos_train.tar.015 https://uofi.box.com/shared/static/wwa4gevipnqen6tg2jlbwtc8rk5fln26.015
fetch sailvos_train.tar.016 https://uofi.box.com/shared/static/uazawpln7k14yj59cvc5b6fq3v246tsb.016
fetch sailvos_train.tar.017 https://uofi.box.com/shared/static/3jzrhnq8myamqidksonmr780mnc5dx6c.017

# Download sailvos_train_annotations.zip
# Amodal and modal segmentation annotations
fetch sailvos_train_annotations.zip https://uofi.box.com/shared/static/lpk44na77obt02h4ry1gmzxadb17x217.zip

# Download train.json
# MSCOCO style json annotation
fetch train.json https://uofi.box.com/shared/static/jbhejcbebzepeg0fmeow4xmtvkxoh4fz.json

# Download the validation set
# RGB frame
fetch sailvos_val.tar.001 https://uofi.box.com/shared/static/ah5sj80zxa71mqdde46g52whlyqi2tp8.001
fetch sailvos_val.tar.002 https://uofi.box.com/shared/static/389bubh56rc99zc214a3twzu73mhmuk8.002
fetch sailvos_val.tar.003 https://uofi.box.com/shared/static/r5czz4ahvgy3yqj6c9sawbfi2z7ref9s.003
fetch sailvos_val.tar.004 https://uofi.box.com/shared/static/ra9ba6j9f0ihljvkt89ujwovkbrqslwc.004
fetch sailvos_val.tar.005 https://uofi.box.com/shared/static/r844e898jbfit520ptvhpbrhqbd7fjr2.005

# Download sailvos_val_annotations.zip
# Amodal and modal segmentation annotations
fetch sailvos_val_annotations.zip https://uofi.box.com/shared/static/rdz38pn6479vjhai4s444ejd004u2dgu.zip

# Download val.json
# MSCOCO style json annotation
fetch val.json https://uofi.box.com/shared/static/hn5iewgvi86f0nq2lsjw4xonv9t5mt2o.json

# # Untar sailvos_train.tar.*. Output: sailvos_train.zip
# cat sailvos_train.tar.* | tar xvf -
# # Untar sailvos_val.tar.*. Output: sailvos_val.zip
# cat sailvos_val.tar.* | tar xvf -

# # unzip all the *.zip files
# unzip sailvos_train.zip # -d train
# unzip sailvos_val.zip # -d val
# unzip sailvos_train_annotations.zip # -d train
# unzip sailvos_val_annotations.zip # -d val

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
