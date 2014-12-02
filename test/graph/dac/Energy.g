# clustered graph example from Derek Bruening's CGO 2005 talk
#=cluster;(C)Max+(U)Max;(C)Min+(U)Max;(C)Min+(U)Min;(C)Rule+(U)Max;(C)TCP+(U)Max;(C)TCP+(U)PI;(C)TCP+(U)Coord.
#=cluster;(C)Max+(U)Max;(C)Min+(U)Max;(C)Rule+(U)Max;(C)TCP+(U)Max;(C)Max+(U)Min;(C)Min+(U)Min;(C)TCP+(U)Min
=cluster;K-LS;K-ILS;ILP;K-LS (All Approximate);
# green instead of gray since not planning on printing this
font=Helvetica
colors=grey1,grey2,med_blue,blue
=table
yformat=%g
max=1.4
=norotate
=noupperright
legendx=right
legendy=center
=nolegoutline
ylabel=Normalized Energy Consumption 
# stretch it out in x direction
xscale=2
yscale=0.8

# 2014 MICRO
#          MaxMax MinMax MinMax RuleMax QoSMax QoSPI QoSCoord
#blackscholes 	1 0.659219635	0.65236987	0.749764551	0.99676967	0.783008104	0.99661993
#bodytrack	1 0.662849828	0.651300721	0.9847729	0.996754691	0.970215751	0.988870411
#canneal	1 0.664130217	0.658265388	0.991045333	1.017805367	0.946231579	1.047480709
#fluidanimate	1 0.668650087	0.647153715	0.990992565	0.997131266	0.90932699	0.997253974
#freqmine	1 0.641655692	0.597102214	0.670586596	0.996892077	0.887288033	0.94532996
#swaptions	1 0.64554776	0.643671976	0.953907496	0.998164219	0.998535252	0.998830995
#vips		1 0.568508595	0.564491742	0.616993215	0.999125109	0.924591633	0.983310963
#x264		1 0.706572097	0.546261878	0.713931809	0.982858851	0.688929594	0.975567133
#geomean		1 0.651069982	0.618631402	0.81995571	0.998148521	0.882801608	0.991300966

# 2015 DAC
#          MaxMax MinMax RuleMax QoSMax MaxMin MinMin QoSMin
#blackscholes	1	0.662094373	0.722352815	0.994761293	0.967506	0.644776884 	0.95859		
#bodytrack	1	0.664574904	0.945611591	0.991765893	0.92502		0.631129167	0.92018		
#canneal		1	0.704029574	0.997050707	1.279184269	0.97496		0.675201129	1.10354	
#fluidanimate	1	0.650026847	0.991139465	0.984163294	0.62027		0.643835616	0.84512		
#freqmine	1	0.658220112	0.686256249	0.976768522	0.75786		0.543833754	0.74898		
#swaptions	1	0.65406795	0.99199157	0.99458861	0.98876		0.618853537	0.98674		
#vips		1	0.708202399	0.68727731	1.104327608	0.95451		0.673189466	1.02747		
#x264		1	0.754288527	0.760576794	0.944827701	0.506033021	0.434776941	0.497726475
#geomean		1	0.681097628	0.836706114	1.029204676	0.81565		0.602766649	0.86413		

fir  	0.6419983130128057		0.6671497584541063 0.6419983130128057	0.6022774327122153
arf  	0.8149435935924197	        0.8149435935924197 0.7802905926777213	0.6050026971878885
sds  	0.8495681253675916	        0.8067841015695253 0.790918723964789	0.7315110508382305
pyr  	0.8012290756443089	        0.7349482043786317 0.7137998191832979	0.7254453706543255
jbmp 	0.8558285772964092	        0.8474514668050241 0.8375934993622587	0.8374205525650172
iir4 	0.6711373845241122	        0.6790829731333163 0.6711373845241122	0.6073819815238579
mv   	0.6910480593148421	        0.7049723078297379 0.654400598508196	0.6383547724328912
ave	
