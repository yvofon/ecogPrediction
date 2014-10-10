%% Common Average Reference

function [gdatCar] = car(gdatFiltNew, groupvector)

for i = 1:max(groupvector);
ind = find(groupvector == i);
AVGcar=mean(gdatFiltNew(ind,:),1); %average over all sensors
AVGcarrep=repmat(AVGcar, size(gdatFiltNew(ind,:),1),1); %array with average with same size as ECOG.data
gdatCar(ind,:)=gdatFiltNew(ind,:)-AVGcarrep;

clear AVGcar AVGcarrep ind
end

srate = 1525.88;
eegplot(gdatFiltNew, 'srate', srate);
eegplot(gdatCar, 'srate', srate);
end