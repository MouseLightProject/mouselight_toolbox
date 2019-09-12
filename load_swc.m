function swc_data = load_swc(swc_file_name)
    %LOADSWC reads a JW formatted swc file and return color/header and data
    %fields
    %
    % [OUTPUTARGS] = LOADSWC(INPUTARGS) Explain usage here
    %
    % Examples:
    %     [swcData,offset,color, header] = loadSWC(swcfile);
    %     swcData(:,3:5) = swcData(:,3:5) + ones(size(swcData,1),1)*offset;
    %     swcData(:,3:5) = swcData(:,3:5)*scale;
    %
    % Provide sample usage code here
    %
    % See also: List related files here

    % $Author: base $	$Date: 2015/08/14 12:09:52 $	$Revision: 0.1 $
    % Copyright: HHMI 2015

    %% parse a swc file
    offset = [0 0 0] ;
    header = cell(1);

    fid = fopen(swc_file_name);
    this_line = fgets(fid);
    skipline = 0;
    header_line_count = 1;
    centerpoint_count = 0 ;
    while ischar(this_line)
        % assumes that all header info is at the top of the swc file
        if strcmp(this_line(1), '#')
            skipline = skipline + 1;
            header{header_line_count} = this_line;
            header_line_count = header_line_count+1;
        else
            centerpoint_count = centerpoint_count + 1 ;
            this_line = fgets(fid);            
            continue;
            %break
        end
        % if get here, tline contains a header line
        if contains(this_line, 'OFFSET') ,
            tokens = strsplit(deblank(this_line)) ;
            tokens_as_double = cellfun(@str2double, tokens) ;
            numeric_tokens = tokens_as_double(~isnan(tokens_as_double)) ;
            if isequal(size(numeric_tokens), [1 3]) ,
                offset = numeric_tokens ;
            else
                error('Unable to parse OFFSET header line: "%s"', this_line) ;
            end
        elseif strcmp(this_line(1:8),'# COLOR ')
            color =cellfun(@str2double,strsplit(deblank(this_line(9:end)),','));  %#ok<NASGU>
        end
        this_line = fgets(fid);
    end
    fclose(fid);

    fid = fopen(swc_file_name);
    for i=1:skipline
        this_line = fgets(fid);  %#ok<NASGU>
    end
    swc_data = zeros(centerpoint_count,7) ;
    this_line = fgets(fid);
    tl = 1;
    while ischar(this_line)
        swc_data(tl,:) = str2num(this_line);  %#ok<ST2NM>
        tl = tl+1;
        this_line = fgets(fid);
    end
    fclose(fid);
    raw_centerpoints = swc_data(:,3:5) ;
    centerpoints = bsxfun(@plus, raw_centerpoints, offset) ;    
    swc_data(:,3:5) = centerpoints ;
end
