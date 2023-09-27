cd /groups/mousebrainmicro/mousebrainmicro/scripts/freezing
out=freeze-2020-12-31.out.txt
bsub -P mouselight -n 8 -oo $out -eo $out /misc/local/matlab-2019a/bin/matlab -nodisplay -batch "modpath; freeze_2020_12_31"
