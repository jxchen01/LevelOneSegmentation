function bool = wekaPathCheck()
%Add the line 'C:\program files\Weka-3-5\weka.jar' to the classpath.txt
%file and restart matlab. Replace '3-5' as necessary depending on the
%version. (To edit, type 'edit classpath.txt').
%
    bool = true;
    w = strfind(javaclasspath('-all'),'weka.jar');
    if(isempty([w{:}]))
        javaaddpath('/Applications/weka-3-6-9.app/Contents/Resources/Java/weka.jar')
         %javaaddpath('E:\Weka\weka.jar');
    else
        return 
    end
   
    w = strfind(javaclasspath('-all'),'weka.jar');
    if(isempty([w{:}]))
        bool = false;
        fprintf('\nPlease add weka.jar to the matlab java class path.\n');
        help wekaPathCheck;
    end
end