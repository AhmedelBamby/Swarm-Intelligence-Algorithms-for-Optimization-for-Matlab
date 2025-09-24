% Eng.Ahmed Hany ElBamby
% work email : ahmedhanyelbamby1102003@gmail.com
% phone : +201096562363 (for work only )

function i=RouletteWheelSelection(P)

    r=rand;
    
    C=cumsum(P);
    
    i=find(r<=C,1,'first');

end