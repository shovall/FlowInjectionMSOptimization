function sample = LoadSample(file_name)
% Loads one mzxml sample file
% NOTE: In order to use this load function a file named mzxmlread_my.m 
% have to be created, which is a modified version of the original Matlab 
% file named 'mzxmlread.m'. 
% Comment out the following line (#465 in Matlab 2017b):  	
% out.scan = out.scan([out.scan.num]);

try
    sample = mzxmlread_my(file_name,'VERBOSE','F');
catch ME
    disp(ME.message)
    sample = NaN;
end
end    
