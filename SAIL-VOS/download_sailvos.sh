#!/bin/sh

# Download the training set
# RGB frame
# Download multiple files at a time to speed up.
wget -v -O sailvos_train.tar.001 -L https://uofi.box.com/shared/static/98e10vflopc6z6w70h6me1acv0aqn4yt.001
wget -v -O sailvos_train.tar.002 -L https://uofi.box.com/shared/static/yrzhc8m1gbz8nkc4eiw33ucz5mck5bbc.002
wget -v -O sailvos_train.tar.003 -L https://uofi.box.com/shared/static/u4bhab5yio7shmdewvooilrpzq9hpr6j.003
wget -v -O sailvos_train.tar.004 -L https://uofi.box.com/shared/static/16hnffnx10a1j8fnwddyscz7mjykrram.004
wget -v -O sailvos_train.tar.005 -L https://uofi.box.com/shared/static/b6kyggl2qke5gpusncg7d4727w2kodrd.005
wget -v -O sailvos_train.tar.006 -L https://uofi.box.com/shared/static/da32234yojvzd0h3h5uvsgyczyj14e79.006
wget -v -O sailvos_train.tar.007 -L https://uofi.box.com/shared/static/hfnmbhbwsz7vix48yxl56xwhisqfp2mh.007
wget -v -O sailvos_train.tar.008 -L https://uofi.box.com/shared/static/c2zy7k4bthtt09ty8z1uyyofwbx5512a.008
wget -v -O sailvos_train.tar.009 -L https://uofi.box.com/shared/static/omwdysb4nh5n4yem21s4pmbqfib0st3s.009
wget -v -O sailvos_train.tar.010 -L https://uofi.box.com/shared/static/vgunuka03mql6p1ihibb5zd80mhd8ayx.010
wget -v -O sailvos_train.tar.011 -L https://uofi.box.com/shared/static/9g3yo3kn6ic4p26bb108cdved1nbvjgz.011
wget -v -O sailvos_train.tar.012 -L https://uofi.box.com/shared/static/ii9z8pww8v50d14nrh5ifksahwksfhn4.012
wget -v -O sailvos_train.tar.013 -L https://uofi.box.com/shared/static/08bcxx3ew59dpuerzx68by59ia02ag29.013
wget -v -O sailvos_train.tar.014 -L https://uofi.box.com/shared/static/m7ikjt28pdskbh05x6v8hsrtyptv3enj.014
wget -v -O sailvos_train.tar.015 -L https://uofi.box.com/shared/static/wwa4gevipnqen6tg2jlbwtc8rk5fln26.015
wget -v -O sailvos_train.tar.016 -L https://uofi.box.com/shared/static/uazawpln7k14yj59cvc5b6fq3v246tsb.016
wget -v -O sailvos_train.tar.017 -L https://uofi.box.com/shared/static/3jzrhnq8myamqidksonmr780mnc5dx6c.017

# Download sailvos_train_annotations.zip
# Amodal and modal segmentation annotations
wget -v -O sailvos_train_annotations.zip -L https://uofi.box.com/shared/static/lpk44na77obt02h4ry1gmzxadb17x217.zip

# Download train.json
# MSCOCO style json annotation
wget -v -O train.json -L https://uofi.box.com/shared/static/jbhejcbebzepeg0fmeow4xmtvkxoh4fz.json

# Download the validation set
# RGB frame
wget -v -O sailvos_val.tar.001 -L https://uofi.box.com/shared/static/ah5sj80zxa71mqdde46g52whlyqi2tp8.001
wget -v -O sailvos_val.tar.002 -L https://uofi.box.com/shared/static/389bubh56rc99zc214a3twzu73mhmuk8.002
wget -v -O sailvos_val.tar.003 -L https://uofi.box.com/shared/static/r5czz4ahvgy3yqj6c9sawbfi2z7ref9s.003
wget -v -O sailvos_val.tar.004 -L https://uofi.box.com/shared/static/ra9ba6j9f0ihljvkt89ujwovkbrqslwc.004
wget -v -O sailvos_val.tar.005 -L https://uofi.box.com/shared/static/r844e898jbfit520ptvhpbrhqbd7fjr2.005

# Download sailvos_val_annotations.zip
# Amodal and modal segmentation annotations
wget -v -O sailvos_val_annotations.zip -L https://uofi.box.com/shared/static/rdz38pn6479vjhai4s444ejd004u2dgu.zip

# Download val.json
# MSCOCO style json annotation
wget -v -O val.json -L https://uofi.box.com/shared/static/hn5iewgvi86f0nq2lsjw4xonv9t5mt2o.json

# # Untar sailvos_train.tar.*. Output: sailvos_train.zip
# cat sailvos_train.tar.* | tar xvf -
# # Untar sailvos_val.tar.*. Output: sailvos_val.zip
# cat sailvos_val.tar.* | tar xvf -

# # unzip all the *.zip files
# unzip sailvos_train.zip # -d train
# unzip sailvos_val.zip # -d val
# unzip sailvos_train_annotations.zip # -d train
# unzip sailvos_val_annotations.zip # -d val

