


tt = 0:0.01:10;
figure

subplot(2,1,1)

[ h,x] = hist(Tall,256);    
hist(Tall,256);
hold on; plot([SPM.u SPM.u],[0 max(h)],'r')
text(SPM.u,max(h),num2str(length(SPM.Z)));


N = histc(Tall,tt);
N_o = N(end:-1:1);
t_o = tt(end:-1:1);

subplot(2,1,2)

 [a ,h1,h2]=plotyy(t_o,cumsum(N_o),t_o,cumsum(N_o));

set(a(2),'yscale','log')        
