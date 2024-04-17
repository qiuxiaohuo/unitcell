%% Description
% calculate E on partitions

E1 = zeros(6,6);
E2 = zeros(6,6);
for i = 1:6
  E1(:,i) = avgptt(cct{i},Node.coord,Elem.VE,1);
  E2(:,i) = avgptt(cct{i},Node.coord,Elem.VE,2);
end