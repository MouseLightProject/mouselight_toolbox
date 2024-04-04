load('vectorField3D_test_inputs.mat') ;
do_cold_stitch = false ;
vecfield3D = vectorField3D(params, scopeloc, do_cold_stitch, regpts, scopeparams, curvemodel) ;
% do_cold_stitch = true ;
% vecfield3D = vectorField3D(params, scopeloc, do_cold_stitch, [], [], []) ;
