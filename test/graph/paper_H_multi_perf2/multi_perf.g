# clustered graph example from Derek Bruening's CGO 2005 talk
#=cluster;(C)Max+(U)Max;(C)Min+(U)Max;(C)Min+(U)Min;(C)Rule+(U)Max;(C)TCP+(U)Max;(C)TCP+(U)Coord.
=cluster;(C)Max;(C)Min;(C)Rule;(C)TCP
# green instead of gray since not planning on printing this
font=Helvetica
colors=grey1,grey2,med_blue,blue
=table
yformat=%g
max=1.2
=norotate
=noupperright
legendx=center
legendy=top
=nolegoutline
=nogridy
=noxlabels
ylabel=Normalized Performance
# stretch it out in x direction
xscale=1.2
yscale=1

#	DAC 2015
#          MaxMax MinMax MinMax RuleMax QoSMax QoSPI QoSCoord
aa	1	0.899211856	0.830324692	0.977839458
bb	1	0.680586378	0.751009573	0.970326604
cc	1	0.642810133	0.712567235	0.995253635
dd	1	0.449420832	0.527186948	1.003425597
ee	1	0.674268768	0.830443904	1.012113439
ff	1	0.762213789	0.932358529	1.030950281
gg	1	0.619893002	0.800205789	0.994969275
hh	1	0.628201468	0.794358404	0.995487219
geomean		1	0.658568300	0.763351200	0.997389000

=yerrorbars
aa	0	0.280199964	0.154765566	0.004773218	
bb	0	0.046059029	0.079592208	0.017686158	
cc	0	0.032933687	0.044792668	0.008749939	
dd	0	0.109770846	0.097803169	0.010666982
ee	0	0.014141402	0.156703453	0.031871096	
ff	0	0.14398735	0.064151723	0.033418557	
gg	0	0.03627398	0.178254894	0.002461932	
hh	0	0.031696469	0.183477916	0.003050684	
geomean	0	0.001925400	0.071678500	0.001332900	

#	Micro 2014
#          MaxMax MinMax MinMax RuleMax QoSMax QoSCoord
#aa 1 0.779782916	0.749739904	0.887731	0.966957952	0.985777118	1
#bb 1 0.655865013	0.599514078	0.806074	0.993025945	0.978413717	1
#fluid.+body 1 0.607732007	0.593055806	0.673407	1.014843257	0.999196352	1
#body.+vips 1 0.632482102	0.622688805	0.780775	0.993504554	0.991726495	1
#black.+freq. 1 0.648937901	0.622149004	0.765581149	0.934660148	0.976953475	1
#swap.+freq. 1 0.668181857	0.63764864	0.844416	0.994505614	0.992202347	1
#x264+vips 1 0.660542919	0.592857034	0.953056718	0.993818908	0.948767679	1
#black.+fluid. 1 0.661131387	0.654142195	0.869276	1.031162736	0.975220866	1
#black.+vips 1 0.652899147	0.640248403	0.870306	1.000573116	0.995218933	1
#fluid.+swap. 1 0.701757087	0.665661444	0.845512	1.050301936	1.057781808	1
#geomean 1 0.665559379	0.636323046	0.824489015	0.996872336	0.989782052	1

=yerrorbars
#aa 0 0.120810106	0.150034724	0.21899	0.03035566	0.009239622		1
#bb 0 0.022215446	0.023907586	0.15282	0.004901921	0.014165247		1
#fluid.+body 0 0.001511855	0.010515395	0.00019	0.034041134	0.048217157	1	
#body.+vips 0 0.007282189	0.006957145	0.11644	0.003945853	0.003736659	1	
#black.+freq. 0 0.007844369	0.025159529	0.102825365	0.059286299	0.019649954	1
#swap.+freq. 0 0.027066622	0.037932026	0.169268	0.002787012	0.018872209	1	
#x264+vips 0 0.031707604	0.030161194	0.020125312	0.005632447	0.033943224	1
#black.+fluid. 0 0.004939581	0.000403135	0.12105	0.03298034	0.023212592	1	
#black.+vips 0 0.003447682	0.014013134	0.12105	0.001864343	0.003485473	1	
#fluid.+swap. 0 0.012137591	0.010348451	0.13705	0.057894269	0.072600814	1	
#geomean 0 0.00536 0.00273 0.05771 0.00232 0.02441	1


