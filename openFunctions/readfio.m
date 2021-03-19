function [varargout] = readfio(filename)
% --- Function to read fio files
% ---
% --- Input : Full file name of the *.fio file
% --- Output: 
% ---            data       : matrix of data values
% ---            counters   : cell of counter names
% ---            cstr       : commandstr for scan
% ---            parameters : content of parameter (%p) section from fio
% ---

displayon   = 0                                                            ;

% --- Initialize and assign output parameters
data        = []                                                           ;
counters    = cell(100,1)                                                  ;
cstr        = ''                                                           ;
parameters  = {}                                                           ; % Store Parameter strings and values in cell array
% ---
varargout{1} = data                                                        ;
varargout{2} = counters                                                    ;
varargout{3} = cstr                                                        ;
varargout{4} = parameters                                                  ;

[fid,~] = fopen(filename,'r')                                              ; % try to open the *.fio file 
if fid == -1
    fclose(fid)                                                            ; % close the file id if it can't be opened
else
    commandsectionstart   = 0                                              ;
    parametersectionstart = 0                                              ;
    datasectionstart      = 0                                              ;
    k                     = 0                                              ; % Parameter line counter
    counternum            = 0                                              ;
    linecounter           = 1                                              ;
    while ~feof(fid)
        tline          = fgetl(fid)                                        ;
        % ---
        Emptyline = 1                                                      ;
        if ~isempty(tline)
            Emptyline = 0                                                  ;
        end
        if Emptyline == 0
            try
                tline = strtrim(tline)                                     ; % remove leading & trailing white spaces of tline
            catch
            end
            Commentline = 0                                                ;
            if numel(tline) >= 1 && strcmpi(tline(1),'!')
                Commentline = 1                                            ;
            end
            if Commentline == 0
                [token,remain] = strtok(tline)                             ;
                % ---
                if ( strcmp(token,'%c') == 1 )
                    commandsectionstart = linecounter + 1                  ;
                end
                if ( strcmp(token,'%p') == 1 )
                    parametersectionstart = linecounter + 1                ;
                end
                if ( strcmp(token,'%d') == 1 )
                    datasectionstart = linecounter + 1                     ;
                end
                % ---
                if (commandsectionstart ~= 0 && linecounter == commandsectionstart)
                    cstr = tline                                           ;
                    if displayon == 1
                        fprintf('%s collected data for this command: %s\r' ...
                            , filename, cstr)                              ;
                    end
                end
                % ---
                if (parametersectionstart ~= 0 && linecounter >= parametersectionstart && datasectionstart == 0)
                    equal_pos = find(tline == '=')                         ;
                    Validline = 0                                          ;
                    if ~isempty(equal_pos) && numel(equal_pos) == 1
                        Validline = 1                                      ;
                    end
                    if Validline == 1
                        left_str  = tline(1:equal_pos-1)                   ;
                        right_str = tline(equal_pos+1:end)                 ;
                        % -------------------------------------------------
                        try
                            left_str = strtrim(left_str)                   ; % remove leading & trailing white spaces of left string
                        catch
                        end
                        try
                            right_str = strtrim(right_str)                 ; % remove  leading & trailing white spaces of right string
                        catch
                        end
                        try
                            right_str(strfind(right_str,'"')) = ''         ; % remove  "s of right string
                        catch
                        end
                        try
                            right_str(strfind(right_str,'''')) = ''        ; % remove  's of right string
                        catch
                        end
                        if (numel(left_str) > 1  && numel(right_str) >= 1 && ~isempty(str2num(right_str)) )
                            k = k + 1                                      ; % increase Modification Line Counter
                            parameters{k,1}  = left_str                    ; % store parameter string in Cell
                            parameters{k,2}  = str2num(right_str)          ; % store parameter in Cell
                        end
                    end
                end
                % ---
                if ( datasectionstart ~= 0 && linecounter >= datasectionstart && strcmp(token,'Col') == 1 )
                    spaces = strfind(remain,' ')                           ;
                    if ( ~isempty(spaces) && numel(spaces) >=3 )
                        counternum = counternum + 1                        ;
                        counters{counternum} = remain(spaces(2)+1:spaces(3)-1) ;
                    end
                end
                if ( datasectionstart ~= 0 && linecounter >= datasectionstart && ~isempty(str2num(token)) )
                    currow = str2num(tline)                                ;
                    data   = [ data; currow]                               ;
                end
            end
        end
        linecounter = linecounter + 1                                      ;
        % ---
    end
    counters(counternum+1:end) = []                                        ;
    fclose(fid)                                                            ; % close the file id
    % --- Assign updated output variables
    varargout{1} = data                                                    ;
    varargout{2} = counters                                                ;
    varargout{3} = cstr                                                    ;
    varargout{4} = parameters                                              ;
    % ---
end

% ---
% EOF
