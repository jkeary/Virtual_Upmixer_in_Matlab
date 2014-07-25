% Name: James Keary 
% Student ID: N12432851 
% NetID: jpk349 
% Due Date: 4/27/2012
% Assignment: Crosstalk Cancellation Implementation in Stereo pair
% 
% FUNCTION DESCRIPTION
%
% VirtualUpmixer
%   takes 2 channel stereo wav file and converts to 3, 4, 5, or 7 speaker 
%   virtual surround sound configurations.  KEMAR HRTFs used.  KEMAR HRTF 
%   impulse responses from http://sound.media.mit.edu/resources/KEMAR.html
%   were used.  
%
% Inputs:
%       1)  INFile          : Name of stereophonic .wav file needing
%                             upmixing
%       2)  channelConfig   : options for channel configuration include
%                               3: 30 right, 0 ahead (center), and -30
%                               left.
%                               4: 30 right, -30 left, 110 back right, and 
%                               -110 back left
%                               5: 30 right, 0 ahead (center), and -30
%                               left, 110 back right, and 
%                               -110 back left.
%                               7: 30 right, 0 ahead (center), and -30
%                               left, 110 back right, -110 back left, 
%                               .
%       3)  OUTFile         : Name of xtalked .wav file to which the  
%                             signal will be written
%
% Output:
%       A virtual surround sound .wav file of the INFile named OUTFile
%

function VirtualUpmixer( filename, channelConfig, OUTfile )

% ---------- ERROR CHECKING -----------

% filename check, make sure your files are strings

if ischar(filename) == 0
    error('filename must be a string')
end

if ischar(OUTfile) == 0
    error('OUTfile must be a string')
end

% The function reads the input .wav file
[y, Fs] = wavread(filename);
RChannel = y(:,1);
LChannel = y(:,2);  
   
% Function makes sure the sampling rates match up.  (The sampling rates of 
% the files I provided and the KEMAR impulse responses line up at 44100.  
% If user chooses to use different 3D input file, and or different HRTF IRs,
% please make sure they are of the same sampling rate.
if Fs ~= 44100 
    error('HRTF IR and signal sampling rates dont match');
end

% Check length of the signal channels to make sure they are the same    
if length(LChannel) > length(RChannel);
    zeropad = length(LChannel) - length(RChannel);
    RChannel = [RChannel; zeros(zeropad, 1)];
end

if length(RChannel) > length(LChannel);
    zeropad = length(RChannel) - length(LChannel);
    LChannel = [LChannel; zeros(zeropad, 1)];
end

% ------------ VARIABLES ------------

% Reads compact data file of HRTF IRs from KEMAR.
% 30
    fp = fopen('L0e030a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	L30 = data(1:256);
    L30Length = length(L30);
    
    fp = fopen('R0e030a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	R30 = data(1:256);
    R30Length = length(R30);
% 110
    fp = fopen('L0e110a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	L110 = data(1:256);
    L110Length = length(L110);
    
    fp = fopen('R0e110a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	R110 = data(1:256);
    R110Length = length(R110);
% 250
    fp = fopen('L0e250a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	L250 = data(1:256);
    L250Length = length(L250);
    
    fp = fopen('R0e250a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	R250 = data(1:256);
    R250Length = length(R250);
% 330
    fp = fopen('L0e330a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	L330 = data(1:256);
    L330Length = length(L330);
    
    fp = fopen('R0e330a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	R330 = data(1:256);
    R330Length = length(R330);
% 0
    fp = fopen('L0e000a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	L000 = data(1:256);
    L000Length = length(L000);
    
    fp = fopen('R0e000a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	R000 = data(1:256);
    R000Length = length(R000);
% 30 azimuth 30 elevation
    fp = fopen('L30e030a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	L3030 = data(1:256);
    L3030Length = length(L3030);
    
    fp = fopen('R30e030a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	R3030 = data(1:256);
    R3030Length = length(R3030);
% 330 azimuth 30 elevation
    fp = fopen('L30e330a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	L30330 = data(1:256);
    L30330Length = length(L30330);
    
    fp = fopen('R30e330a.dat','r','ieee-be');
	data = fread(fp, 256, 'short');
	fclose(fp);
	R30330 = data(1:256);
    R30330Length = length(R30330);

% ---------- COMPUTATIONS -----------
if channelConfig == 2
    L30 = conv(L30, LChannel); 
    R30 = conv(R30, RChannel); 
    L330 = conv(L330, LChannel);
    R330 = conv(R330, RChannel);
    
    % Allocate left and right channel matrices.
    MTXleft = zeros(length(L30), 2);
    MTXright = zeros(length(L30), 2);
    
    % Place vectors in channel matrices.  
    MTXleft(:,1) = L30;
    MTXleft(:,2) = L330;
    
    MTXright(:,1) = R30;
    MTXright(:,2) = R330;
    
    % add rows of the matrices to get 2 channels for VIRTUAL surround sound.
    % BUT FIRST... allocate some vectors and output matrix.
    leftVEC = zeros(length(MTXleft), 1);
    rightVEC = zeros(length(MTXright), 1);
    outputMTX = zeros(length(leftVEC), 2);
    
    % sum rows of MTXleft and place into leftVEC, same for MTXright into rightVEC
    MTXleft = MTXleft';
    MTXright = MTXright';
    
    sumLEFTrow = (sum(MTXleft))/3;
    sumRIGHTrow = (sum(MTXright))/3;
    
    leftVEC = sumLEFTrow';
    rightVEC = sumRIGHTrow';
    
    % then put together into outputMTX
    outputMTX(:,1) = rightVEC;
    outputMTX(:,2) = leftVEC;
    
    % normalize 
    vectorMAX = 1.001 * (max(abs(outputMTX)));
    outputMTX = outputMTX / max(vectorMAX);
    
    % wavwrite
    wavwrite (outputMTX, 44100, OUTfile); 
    
elseif channelConfig == 3
    % CONVOLVE FRONT CHANNEL SIGNALS WITH HRTFs FOR FRONT SOUND DESIGN
    L30 = conv(L30, LChannel); 
    R30 = conv(R30, RChannel); 
    L330 = conv(L330, LChannel);
    R330 = conv(R330, RChannel);
    L000 = conv(L000, LChannel);
    R000 = conv(R000, RChannel);
    
    % Allocate left and right channel matrices.
    MTXleft = zeros(length(L30), 3);
    MTXright = zeros(length(L30), 3);
    
    % Place vectors in channel matrices.  
    MTXleft(:,1) = L30;
    MTXleft(:,2) = L330;
    MTXleft(:,3) = L000;
    
    MTXright(:,1) = R30;
    MTXright(:,2) = R330;
    MTXright(:,3) = R000;
    
    % add rows of the matrices to get 2 channels for VIRTUAL surround sound.
    % BUT FIRST... allocate some vectors and output matrix.
    leftVEC = zeros(length(MTXleft), 1);
    rightVEC = zeros(length(MTXright), 1);
    outputMTX = zeros(length(leftVEC), 2);
    
    % sum rows of MTXleft and place into leftVEC, same for MTXright into rightVEC
    MTXleft = MTXleft';
    MTXright = MTXright';
    
    sumLEFTrow = (sum(MTXleft))/3;
    sumRIGHTrow = (sum(MTXright))/3;
    
    leftVEC = sumLEFTrow';
    rightVEC = sumRIGHTrow';
    
    % then put together into outputMTX
    outputMTX(:,1) = rightVEC;
    outputMTX(:,2) = leftVEC;
    
    % normalize 
    vectorMAX = 1.001 * (max(abs(outputMTX)));
    outputMTX = outputMTX / max(vectorMAX);
    
    % wavwrite
    wavwrite (outputMTX, 44100, OUTfile);  

elseif channelConfig == 4
    % CONVOLVE FRONT LEFT AND RIGHT CHANNEL SIGNALS WITH HRTFs FOR FRONT  
    % SOUND DESIGN. NO CENTER CHANNEL IN THIS CONFIGURATION.
    L30 = conv(L30, LChannel); 
    R30 = conv(R30, RChannel); 
    L330 = conv(L330, LChannel);
    R330 = conv(R330, RChannel);
    
    % START DESIGNING THE BACK AMBIANT SOUND FIELD, NEED TO MODEL OFF FRONT
    % CHANNELS.  SO MAKE FRONT MONO CHANNELS
    C30 = (L30 + R30)/2;
    C330 = (L330 + R330)/2;
    
    % find difference of front channels, normalize for scaling vector
    diffVec = C30 - C330;
    scalersVec = max(abs(diffVec));
    
    % scale front L and R channels.  Stays the same @ biggest difference 
    % between L and R front channels, and goes to zero @ smallest difference. 
    R = C30 .* scalersVec;
    L = C330 .* scalersVec;

    % Subtract this from front channels to leave you with the Ambiant sounds.
    % i.e. sound energy when L and R channel are equal.  This is based on
    % interaural time difference model of basic waveform.  The greater the
    % difference in vector points the greater the interaural differences and
    % cues.  Thus when points are the same, the sound is more ambiant, and when 
    % points are different, stereo reverberation causes spatial cues. 
    CLeftBack = (C30 - R);
    CRightBack = (C330 - L);
    
    % CONVOLVE BACK CHANNELS WITH HRTFs FOR BACK AMBIANT SOUND FIELD DESIGN
    L250 = conv(L250, CLeftBack); 
    R250 = conv(R250, CLeftBack); 
    L110 = conv(L110, CRightBack); 
    R110 = conv(R110, CRightBack);

    % make sure channel lengths are the same
    lengthBacks = length(L110);
    lengthFronts = length(L30);
    
        if lengthBacks > lengthFronts
            zeropad = zeros(lengthBacks - lengthFronts, 1);
            L30 = [L30; zeropad];
            R30 = [R30; zeropad];
            L330 = [L330; zeropad];
            R330 = [R330; zeropad];
        end
    
        if lengthFronts > lengthBacks
            zeropad = zeros(lengthFronts - lengthBacks, 1);
            L250 = [L250; zeropad];
            R250 = [R250; zeropad];
            L110 = [L110; zeropad];
            R110 = [R110; zeropad];
        end
        
    lengthFronts = length(L30);
    lengthBacks = length(L110);
    
    % Allocate left and right channel matrices.
    MTXleft = zeros(lengthFronts, 4);
    MTXright = zeros(lengthBacks, 4);
    
    % Place vectors in channel matrices.  
    MTXleft(:,1) = L30;
    MTXleft(:,2) = L110;
    MTXleft(:,3) = L250;
    MTXleft(:,4) = L330;
    
    MTXright(:,1) = R30;
    MTXright(:,2) = R110;
    MTXright(:,3) = R250;
    MTXright(:,4) = R330;
    
    % add rows of the matrices to get 2 channels for VIRTUAL surround sound.
    % BUT FIRST... allocate some vectors and output matrix.
    leftVEC = zeros(length(MTXleft), 1);
    rightVEC = zeros(length(MTXright), 1);
    outputMTX = zeros(length(leftVEC), 2);
    
    % sum rows of MTXleft and place into leftVEC, same for MTXright into rightVEC
    MTXleft = MTXleft';
    MTXright = MTXright';
    
    sumLEFTrow = (sum(MTXleft))/4;
    sumRIGHTrow = (sum(MTXright))/4;
    
    leftVEC = sumLEFTrow';
    rightVEC = sumRIGHTrow';
    
    % then put together into outputMTX
    outputMTX(:,1) = rightVEC;
    outputMTX(:,2) = leftVEC;
    
    % normalize 
    vectorMAX = 1.001 * (max(abs(outputMTX)));
    outputMTX = outputMTX / max(vectorMAX);
    
    % wavwrite
    wavwrite (outputMTX, 44100, OUTfile); 


% If 5 Channel
elseif channelConfig == 5
    % CONVOLVE FRONT CHANNEL SIGNALS WITH HRTFs FOR FRONT SOUND DESIGN
    L30 = conv(L30, LChannel); 
    R30 = conv(R30, RChannel); 
    L330 = conv(L330, LChannel);
    R330 = conv(R330, RChannel);
    L000 = conv(L000, LChannel);
    R000 = conv(R000, RChannel);
    
    % START DESIGNING THE BACK AMBIANT SOUND FIELD, NEED TO MODEL OFF FRONT
    % CHANNELS.  SO MAKE FRONT MONO CHANNELS
    C30 = (L30 + R30)/2;
    C330 = (L330 + R330)/2;
    
    % find difference of front channels, normalize for scaling vector
    diffVec = C30 - C330;
    scalersVec = max(abs(diffVec));
    
    % scale front L and R channels.  Stays the same @ biggest difference 
    % between L and R front channels, and goes to zero @ smallest difference. 
    R = C30 .* scalersVec;
    L = C330 .* scalersVec;

    % Subtract this from front channels to leave you with the Ambiant sounds.
    % i.e. sound energy when L and R channel are equal.  This is based on
    % interaural time difference model of basic waveform.  The greater the
    % difference in vector points the greater the interaural differences and
    % cues.  Thus when points are the same, the sound is more ambiant, and when 
    % points are different, stereo reverberation causes spatial cues. 
    CLeftBack = (C30 - R);
    CRightBack = (C330 - L);
    
    % CONVOLVE BACK CHANNELS WITH HRTFs FOR BACK AMBIANT SOUND FIELD DESIGN
    L250 = conv(L250, CLeftBack); 
    R250 = conv(R250, CLeftBack); 
    L110 = conv(L110, CRightBack); 
    R110 = conv(R110, CRightBack);

    % make sure channel lengths are the same
    lengthBacks = length(L110);
    lengthFronts = length(L30);
    
        if lengthBacks > lengthFronts
            zeropad = zeros(lengthBacks - lengthFronts, 1);
            L30 = [L30; zeropad];
            R30 = [R30; zeropad];
            L000 = [L000; zeropad];
            R000 = [R000; zeropad];
            L330 = [L330; zeropad];
            R330 = [R330; zeropad];
        end
    
        if lengthFronts > lengthBacks
            zeropad = zeros(lengthFronts - lengthBacks, 1);
            L250 = [L250; zeropad];
            R250 = [R250; zeropad];
            L110 = [L110; zeropad];
            R110 = [R110; zeropad];
        end
        
    lengthFronts = length(L30);
    lengthBacks = length(L110);
    
    % Allocate left and right channel matrices.
    MTXleft = zeros(lengthFronts, 5);
    MTXright = zeros(lengthBacks, 5);
    
    % Place vectors in channel matrices.  
    MTXleft(:,1) = L30;
    MTXleft(:,2) = L110;
    MTXleft(:,3) = L250;
    MTXleft(:,4) = L330;
    MTXleft(:,5) = L000;
    
    MTXright(:,1) = R30;
    MTXright(:,2) = R110;
    MTXright(:,3) = R250;
    MTXright(:,4) = R330;
    MTXright(:,5) = R000;
    
    % add rows of the matrices to get 2 channels for VIRTUAL surround sound.
    % BUT FIRST... allocate some vectors and output matrix.
    leftVEC = zeros(length(MTXleft), 1);
    rightVEC = zeros(length(MTXright), 1);
    outputMTX = zeros(length(leftVEC), 2);
    
    % sum rows of MTXleft and place into leftVEC, same for MTXright into rightVEC
    MTXleft = MTXleft';
    MTXright = MTXright';
    
    sumLEFTrow = (sum(MTXleft))/5;
    sumRIGHTrow = (sum(MTXright))/5;
    
    leftVEC = sumLEFTrow';
    rightVEC = sumRIGHTrow';
    
    % then put together into outputMTX
    outputMTX(:,1) = rightVEC;
    outputMTX(:,2) = leftVEC;
    
    % normalize 
    vectorMAX = 1.001 * (max(abs(outputMTX)));
    outputMTX = outputMTX / max(vectorMAX);
    
    % wavwrite
    wavwrite (outputMTX, 44100, OUTfile);  

elseif channelConfig == 7
    % CONVOLVE FRONT CHANNEL SIGNALS WITH HRTFs FOR FRONT SOUND DESIGN
    L3030 = conv(L3030, LChannel); 
    R3030 = conv(R3030, RChannel); 
    L30330 = conv(L30330, LChannel);
    R30330 = conv(R30330, RChannel);

    % HIGHPASS FILTER THE CHANNELS
    Wn = 1000 / (Fs/2);
    [b_hi, a_hi] = butter(2, Wn, 'high');
    
    % filter audio
    L3030 = filter(b_hi, a_hi, L3030);
    R3030 = filter(b_hi, a_hi, R3030);
    L30330 = filter(b_hi, a_hi, L30330);
    R30330 = filter(b_hi, a_hi, R30330);
    
    % CONVOLVE FRONT CHANNEL SIGNALS WITH HRTFs FOR FRONT SOUND DESIGN
    L30 = conv(L30, LChannel); 
    R30 = conv(R30, RChannel); 
    L330 = conv(L330, LChannel);
    R330 = conv(R330, RChannel);
    L000 = conv(L000, LChannel);
    R000 = conv(R000, RChannel);
    
    % START DESIGNING THE BACK AMBIANT SOUND FIELD, NEED TO MODEL OFF FRONT
    % CHANNELS.  SO MAKE FRONT MONO CHANNELS
    C30 = (L30 + R30)/2;
    C330 = (L330 + R330)/2;
    
    % find difference of front channels, normalize for scaling vector
    diffVec = C30 - C330;
    scalersVec = max(abs(diffVec));
    
    % scale front L and R channels.  Stays the same @ biggest difference 
    % between L and R front channels, and goes to zero @ smallest difference. 
    R = C30 .* scalersVec;
    L = C330 .* scalersVec;

    % Subtract this from front channels to leave you with the Ambiant sounds.
    % i.e. sound energy when L and R channel are equal.  This is based on
    % interaural time difference model of basic waveform.  The greater the
    % difference in vector points the greater the interaural differences and
    % cues.  Thus when points are the same, the sound is more ambiant, and when 
    % points are different, stereo reverberation causes spatial cues. 
    CLeftBack = (C30 - R);
    CRightBack = (C330 - L);
    
    % CONVOLVE BACK CHANNELS WITH HRTFs FOR BACK AMBIANT SOUND FIELD DESIGN
    L250 = conv(L250, CLeftBack); 
    R250 = conv(R250, CLeftBack); 
    L110 = conv(L110, CRightBack); 
    R110 = conv(R110, CRightBack);

    % make sure channel lengths are the same
    lengthBacks = length(L110);
    lengthFronts = length(L30);
    lengthUps = length(L3030);
    
        if lengthBacks > lengthFronts
            zeropad = zeros(lengthBacks - lengthFronts, 1);
            L30 = [L30; zeropad];
            R30 = [R30; zeropad];
            L000 = [L000; zeropad];
            R000 = [R000; zeropad];
            L330 = [L330; zeropad];
            R330 = [R330; zeropad];
            largerLength = lengthBacks;
        end
    
        if lengthFronts > lengthBacks
            zeropad = zeros(lengthFronts - lengthBacks, 1);
            L250 = [L250; zeropad];
            R250 = [R250; zeropad];
            L110 = [L110; zeropad];
            R110 = [R110; zeropad];
            largerLength = lengthFronts;
        end
        
        if lengthUps > largerLength
           zeropad = zeros(lengthUps - largerLength, 1);
           L30 = [L30; zeropad];
           R30 = [R30; zeropad];
           L000 = [L000; zeropad];
           R000 = [R000; zeropad];
           L330 = [L330; zeropad];
           R330 = [R330; zeropad];
           L250 = [L250; zeropad];
           R250 = [R250; zeropad];
           L110 = [L110; zeropad];
           R110 = [R110; zeropad];
           largestLength = lengthUps;
        end
        if lengthUps < largerLength
           zeropad = zeros(largerLength - lengthUps, 1); 
           L3030 = [L3030; zeropad];
           R3030 = [R3030; zeropad];
           L30330 = [L30330; zeropad];
           R30330 = [R30330; zeropad];
           largestLength = largerLength;
        end
    
    % Allocate left and right channel matrices.
    MTXleft = zeros(largestLength, 7);
    MTXright = zeros(largestLength, 7);
    
    % Place vectors in channel matrices.  
    MTXleft(:,1) = L30;
    MTXleft(:,2) = L110;
    MTXleft(:,3) = L250;
    MTXleft(:,4) = L330;
    MTXleft(:,5) = L000;
    MTXleft(:,6) = L3030;
    MTXleft(:,7) = L30330;
    
    MTXright(:,1) = R30;
    MTXright(:,2) = R110;
    MTXright(:,3) = R250;
    MTXright(:,4) = R330;
    MTXright(:,5) = R000;
    MTXright(:,6) = R3030;
    MTXright(:,7) = R30330;
    
    % add rows of the matrices to get 2 channels for VIRTUAL surround sound.
    % BUT FIRST... allocate some vectors and output matrix.
    leftVEC = zeros(length(MTXleft), 1);
    rightVEC = zeros(length(MTXright), 1);
    outputMTX = zeros(length(leftVEC), 2);
    
    % sum rows of MTXleft and place into leftVEC, same for MTXright into rightVEC
    MTXleft = MTXleft';
    MTXright = MTXright';
    
    sumLEFTrow = (sum(MTXleft))/7;
    sumRIGHTrow = (sum(MTXright))/7;
    
    leftVEC = sumLEFTrow';
    rightVEC = sumRIGHTrow';
    
    % then put together into outputMTX
    outputMTX(:,1) = rightVEC;
    outputMTX(:,2) = leftVEC;
    
    % normalize 
    vectorMAX = 1.001 * (max(abs(outputMTX)));
    outputMTX = outputMTX / max(vectorMAX);
    
    % wavwrite
    wavwrite (outputMTX, 44100, OUTfile);  
else
    channelConfig == 6 || 9 || 10 || 22
    error('function does not yet support this channel configuration')
end

end

