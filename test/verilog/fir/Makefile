fir: fir.v fir_variance.v fir_accurate.v interface.v edge.v scalers.v declarations.v parameters.v
	vcs  +incdir+../resources/AMA_appr4_32bit_8appr+../resources/jiehan_bth+../resources/mul_appr_16cmps_bth -sverilog  +v2k fir.v -o $@
r: fir
	./fir +T=20000

