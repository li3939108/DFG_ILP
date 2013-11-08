#include "PLP_Router.h"
#include <iostream>
#include "ReadWriteFile.h"

void PLP_Router::build_model()
{
#ifdef DISPLAY
	cout<<"\tbuilding model...\n";
#endif
	int idx = 1;
	for(PHYSICAL_EDGEITER eiter=edges(PhyG).first;eiter!=edges(PhyG).second;eiter++)
	{
		Link2Idx[*eiter] = Ntotal+idx;
		idx++;
		Link2PathIdx[*eiter].resize(PhySS.size());
	}
	PathDynamic.assign(Ntotal,0);
	idx = 0;
	for(unsigned int i=0;i<Paths.size();i++)
	{
		for(unsigned int j=0;j<Paths[i].size();j++)
		{
			for(unsigned int l=0;l<Paths[i][j].size();l++)
			{
				float tmp = 0;
				for(unsigned int k=2;k<Paths[i][j][l].size()-1;k++)
				{
					tmp+=EdgeDynamic[ResrcG[edge(Paths[i][j][l][k-1],Paths[i][j][l][k],ResrcG).first].e];
				}
				PathDynamic[idx] = mode_weight[i]*tmp;
				idx++;
			}
		}
	}

	lp = make_lp(0,Ntotal+num_edges(PhyG));

	set_add_rowmode(lp,true);
	//capacity constraints
	for(RESRC_EDGEITER eiter=edges(ResrcG).first;eiter!=edges(ResrcG).second;eiter++)
	{
		if(ResrcG[*eiter].is_superedge||(Edge2PathIdx.count(*eiter)==0)) continue;
		//add capacity constraints
		for(unsigned int k=0;k<PhySS.size();k++)
		{
			vector<unsigned int> tmp = Edge2PathIdx[*eiter][k];
			REAL *row = new REAL[tmp.size()+1];
			int *colno = new int[tmp.size()+1];
			for(unsigned int i=0;i<tmp.size();i++)
			{
				row[i] = 1;
				colno[i] = tmp[i];
				Link2PathIdx[ResrcG[*eiter].e][k].push_back(tmp[i]);
			}
			row[tmp.size()] = -1;
			colno[tmp.size()] = Link2Idx[ResrcG[*eiter].e];
			add_constraintex(lp,tmp.size()+1,row,colno,LE,0);
			delete [] row;
			delete [] colno;
		}
	}
	//demand incentives
	idx = 1;
	for(unsigned int k=0;k<Paths.size();k++)
	{
		for(unsigned int i=0;i<Paths[k].size();i++)
		{
			REAL *row = new REAL[Paths[k][i].size()];
			int *colno = new int[Paths[k][i].size()];
			for(unsigned int j=0;j<Paths[k][i].size();j++)
			{
				row[j] = 1;
				colno[j] = idx;
				idx++;
			}
			add_constraintex(lp,Paths[k][i].size(),row,colno,EQ,1);
			delete [] row;
			delete [] colno;
		}
	}
	//minimal residual bandwidth constraints
	for(unsigned int k=0;k<PhySS.size();k++)
	{
		for(PHYSICAL_EDGEITER eiter=edges(PhyG).first;eiter!=edges(PhyG).second;eiter++)
		{
			vector<int> tmp = Link2PathIdx[*eiter][k];
			map<int,int> LinkCnt;//how many times current link is used by paths
			for(unsigned int i=0;i<tmp.size();i++)
			{
				LinkCnt[tmp[i]] = 0;
			}
			for(unsigned int i=0;i<tmp.size();i++)
			{
				LinkCnt[tmp[i]]++;
			}
			REAL *row = new REAL[LinkCnt.size()+1];
			int *colno = new int[LinkCnt.size()+1];
			unsigned i=0;
			for(map<int,int>::iterator iter=LinkCnt.begin();iter!=LinkCnt.end();iter++)
			{
				row[i] = iter->second;
				colno[i] = iter->first;
				i++;
			}
			row[LinkCnt.size()] = -float(Twindow);
			colno[LinkCnt.size()] = Link2Idx[*eiter];
			add_constraintex(lp,LinkCnt.size()+1,row,colno,LE,-float(ceil(MinRes[*eiter]*Twindow)));
			delete [] row;
			delete [] colno;
		}
	}//*/
	//in order delivery
#ifndef MINIMAL
	/*
	vector<unsigned int> tmp;//no of total paths of first n ss pair
	tmp.push_back(0);
	for(unsigned int i=1;i<Paths.size();i++)
	{
		tmp.push_back(Paths[i].size()+tmp[i-1]);
	}
	for(unsigned int i=0;i<InOrdDeliv.size();i++)
	{
		for(unsigned int j=1;j<InOrdDeliv[i].size();j++)
		{
			unsigned int flit_prev = InOrdDeliv[i][j-1];
			unsigned int flit_curr = InOrdDeliv[i][j];
			REAL *row = new REAL[Paths[flit_prev].size()+Paths[flit_curr].size()];
			int *colno = new int[Paths[flit_prev].size()+Paths[flit_curr].size()];
			for(unsigned int k=0;k<Paths[flit_prev].size();k++)
			{
				row[k] = Paths[flit_prev][k].size();//length of previous flit path
				colno[k] = tmp[flit_prev]+k+1;
			}
			for(unsigned int k=0;k<Paths[flit_curr].size();k++)
			{
				row[k+Paths[flit_prev].size()] = -REAL(Paths[flit_curr][k].size());//-length of current flit path
				colno[k+Paths[flit_prev].size()] = tmp[flit_curr]+k+1;
			}
			add_constraintex(lp,Paths[flit_prev].size()+Paths[flit_curr].size(),row,colno,LE,0);
			delete [] row;
			delete [] colno;
		}
	}//*/
#endif
	set_add_rowmode(lp,false);
	//max capacity constraints
	for(PHYSICAL_EDGEITER eiter=edges(PhyG).first;eiter!=edges(PhyG).second;eiter++)
	{
		set_upbo(lp, Link2Idx[*eiter], MaxCap[*eiter]);
	}
	for(unsigned int i=1;i<=Ntotal;i++)
		set_binary(lp, i, TRUE);
	for(unsigned int i=Ntotal+1;i<=Ntotal+num_edges(PhyG);i++)
		set_int(lp, i, TRUE);
	set_minim(lp);
	set_mip_gap(lp,TRUE,1e-2);
	set_timeout(lp,3600);
	set_break_at_first(lp,TRUE);
	//set_verbose(lp,IMPORTANT);
}

void PLP_Router::compute()
{	
	clock_t t_clk = clock();
	//set objective on LP solver
	REAL *row = new REAL[Ntotal+num_edges(PhyG)+1];
	row[0] = 0;
	for(unsigned int i=1;i<Ntotal+num_edges(PhyG)+1;i++)
		row[i] = Grad[i-1];
	set_obj_fn(lp,row);
	delete [] row;
	//reset_basis(lp);
	//retrieve solution
#ifdef DISPLAY
	cout<<"\tsolving LP...\n";
#endif
	int rslt = solve(lp);
	if(rslt==OPTIMAL)  {cout<<"\toptimal solution attained\n"; }
	else if(rslt==SUBOPTIMAL) {cout<<"\tsuboptimal solution attained\n";}
	else {cout<<"\tunable to solve LP\n";Store("./TP/rslt.txt",string("infeasible"));return;}
	REAL *sltn = new REAL[1+get_Nrows(lp)+get_Ncolumns(lp)];
	get_primal_solution(lp,sltn);
	for(int i=0;i<get_Ncolumns(lp);i++)
	{
		Sltn[i] = sltn[i+1+get_Nrows(lp)];
	}
	delete [] sltn;
	//calculate the total power consumption
	Dynamic = 0;
	LinkStatic = 0;
	RouterStatic = 0;
	int idx = 1;
	for(unsigned int k=0;k<Paths.size();k++)
	{
		for(unsigned int i=0;i<Paths[k].size();i++)
		{
			for(unsigned int j=0;j<Paths[k][i].size();j++)
			{
				if(Sltn[idx-1])
				{
					Dynamic+=PathDynamic[idx-1];
#ifdef DISPLAY
					vector<unsigned int> tmp;
					for(unsigned int l=1;l<Paths[k][i][j].size()-1;l++)
					{
						tmp.push_back(Paths[k][i][j][l]%num_vertices(PhyG));
						cout<<Paths[k][i][j][l]%num_vertices(PhyG)<<"\t";//":"<<Paths[k][i][j][l]<<"\t";
					}
					//Store("./TP/rslt.txt",tmp);
					cout<<endl;
#endif
				}
				idx++;
			}
		}
	}
	cout<<"\tdynamic power = "<<Dynamic<<"\n";
	total_cap = 0;
	total_buff = 0;
	Link_uti = 0;
	float Link_sum = 0;
	for(PHYSICAL_EDGEITER eiter=edges(PhyG).first;eiter!=edges(PhyG).second;eiter++)
	{
		unsigned int capacity = Sltn[Link2Idx[*eiter]-1];
		if(source(*eiter,PhyG)==target(*eiter,PhyG)) total_buff+=capacity;
		else total_cap+=capacity;

#ifdef DISPLAY
		if((capacity==0)) continue;//||(source(*eiter,PhyG)==target(*eiter,PhyG))) continue;
		cout<<source(*eiter,PhyG)<<"-"<<target(*eiter,PhyG)<<":"<<capacity<<"\t";
		for(unsigned int k=0;k<Paths.size();k++)
		{
			vector<int> tmp = Link2PathIdx[*eiter][k];
			map<int,int> LinkCnt;//how many times current link is used by paths
			for(unsigned int i=0;i<tmp.size();i++)
			{
				LinkCnt[tmp[i]] = 0;
			}
			for(unsigned int i=0;i<tmp.size();i++)
			{
				LinkCnt[tmp[i]]++;
			}
			float s=0;
			for(map<int,int>::iterator iter=LinkCnt.begin();iter!=LinkCnt.end();iter++)
			{
				s += iter->second*Sltn[iter->first-1];
			}
			Link_uti+=s+MinRes[*eiter]*Twindow;
			Link_sum+=capacity*Twindow;
			cout<<s/float(capacity*Twindow)+MinRes[*eiter]<<"/";
		}
		cout<<endl;
#endif
		LinkStatic+=EdgeStatic[*eiter]*capacity*Twindow;
	}
	//Link_uti = Link_uti/Link_sum;
	cout<<"\tlink utilization = "<<Link_uti<<"/"<<Link_sum<<endl;
	cout<<"\tlink power = "<<LinkStatic<<endl;
	for(PHYSICAL_VERTITER viter = vertices(PhyG).first;viter!=vertices(PhyG).second;viter++)
	{
		bool deletable = true;
		for(PHYSICAL_OUTEDGEITER outiter=out_edges(*viter,PhyG).first;outiter!=out_edges(*viter,PhyG).second;outiter++)
		{
			if(Sltn[Link2Idx[*outiter]-1]>0)
			{
				deletable = false;
				break;
			}
		}
		for(PHYSICAL_INEDGEITER initer=in_edges(*viter,PhyG).first;initer!=in_edges(*viter,PhyG).second;initer++)
		{
			if(Sltn[Link2Idx[*initer]-1]>0)
			{
				deletable = false;
				break;
			}
		}
		if(!deletable)
			RouterStatic+=VertexStatic[*viter]*Twindow;
		else
			cout<<*viter<<" deleted\n";
	}
	cout<<"\ttotal power = "<<RouterStatic<<endl;
	success = true;
	t_clk = clock()-t_clk;
	Time_compute = float(t_clk)/CLOCKS_PER_SEC;
	cout<<"\tcompute time = "<<Time_compute<<endl;
}


