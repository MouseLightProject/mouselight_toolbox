function modpath()
    this_folder_path = fileparts(mfilename('fullpath')) ;
    toolbox_modpath_path = fullfile(this_folder_path, 'mouselight_toolbox', 'modpath.m') ;
    run(toolbox_modpath_path) ;
end
