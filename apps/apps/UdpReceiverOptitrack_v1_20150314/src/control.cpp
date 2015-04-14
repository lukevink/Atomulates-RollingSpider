#include <math.h>
#include <iostream>

using namespace std;

#include "control.h"

double diff[3][3];
double integral[3];

double mx = 0.0, my = 0.0, mz = 0.0, mp = 0.0, mr = 0.0, mya = 0.0, lastSetMy = 0.0;
double gmx = 0, gmy = 0.80, gmz = 0, gmp = 0.0, gmr = 0.0, gmya = 0;

clock_t  clock1;
clock_t  clock2;
double elapse=0;
int start_pid = 0;

//Tal's test defaults
double gainx[3] = {0.85, 0., 6.8};
double gainy[3] = {0.85, 0., 6.8};
double gainz[3] = {0.7, 0., 7.6};

//Hysteresis [range to stop, range to re-start, min_loiter_time]
double hysterx[3] = { 0.1, 0.3 , 0.6};
double hystery[3] = { 0.1, 0.3 , 0.6};
double hysterz[3] = { 0.05, 0.12 , 0.1};

//used to maintain state, X_hyster=true (1) means we were 'close enough' (see above) to shut off external PID.
int x_hyster = 0;
int y_hyster = 0;
int z_hyster = 0;


void set_x_z_y_o(double x, double z, double y, double o){
    gmx = x;
    gmz = z;
    gmy = y;
    gmya = o;
    
    integral[0] = 0.f;
    integral[1] = 0.f;
    integral[2] = 0.f;
}

float pid_control(double t, double v, double *ing, double *pre, double gain[3], double dtime){
    double err = t - v;
    float ret, dt;
    *ing += err * dtime;
    dt = err - *pre;
    *pre = err;
    ret = gain[0] * (err + (*ing)/gain[1] + dt*gain[2]);
    
	return ret; //ret = gain[0] * err;
}

float pid_control2_x(double goal, double now, double gain[3], double dtime){
	diff[0][0]=diff[0][1]; 
	diff[0][1] = goal-now;

        integral[0] += (diff[0][0]+diff[0][1]) / 2.0 * dtime;
    
	float ret = gain[0] *diff[0][1] + gain[1]*integral[0] + gain[2]*(diff[0][1]-diff[0][0])/dtime;
	//cout<<"X: "<<ret<<" "<<diff[0][1]<<" "<<(double)(diff[0][1]-diff[0][0])<<" "<<integral<<" "<<(int)dtime<<endl;
    //printf("X: %f %f %f \n", ret, diff[0][1], diff[0][1] - diff[0][0]);

	//should P component also be (diff[0]+diff[1]) / 2.0?
    return ret;
}

float pid_control2_z(double goal, double now, double gain[3], double dtime){
	diff[1][0]=diff[1][1]; 
	diff[1][1] = goal-now;
   
    integral[1] += (diff[1][0]+diff[1][1]) / 2.0 * dtime; //TODO: ask Sang -- why was this "1+diff[1][1]"?
 
	float ret = gain[0] *diff[1][1] + gain[1]*integral[1] + gain[2]*(diff[1][1]-diff[1][0])/dtime;
	//cout<<"Z: "<<ret<<" "<<diff[1][1]<<" "<<diff[1][1]-diff[1][0]<<" "<<integral<<" "<<dtime<<endl;

	//should P component also be (diff[0]+diff[1]) / 2.0?
    return ret;
}

//height of the drone
float pid_control2_y(double goal, double now, double gain[3], double dtime){
	diff[2][0]=diff[2][1]; 
	diff[2][1] = goal-now;
   
    integral[2] += (diff[2][0]+diff[2][1]) / 2.0 * dtime;
 
	float ret = gain[0] *diff[2][1] + gain[1]*integral[2] + gain[2]*(diff[2][1]-diff[2][0])/dtime;
	//cout<<"Y: "<<ret<<" "<<diff[2][1]<<" "<<diff[2][1]-diff[2][0]<<" "<<integral<<" "<<dtime<<endl;

	//should P component also be (diff[0]+diff[1]) / 2.0?
    return ret;
}

void drone_control(float *p, float *r, float *y, float *g){
    
	float roll = 0., pitch = 0., gaz= 0., yaw=0;

    /*
    int yaw_change = 0;
	static int flag = 0;
			
	const double reps1 = 0.087222222 * 1;
	const double reps2 = 3.141592 * 3.0 / 4.0;
	double dyaw = gmya - mya;
			
	dyaw = dyaw > 3.141592 ? -6.28318 + dyaw : dyaw;
	dyaw = dyaw < -3.141592 ? 6.28318 + dyaw : dyaw;

	if (1 || flag == 0)
	{
		if(dyaw > reps1)
		{
			yaw = -1.0;
			yaw_change = 1;
			flag = -1;
		}
		else if(dyaw < -reps1)
		{
			yaw = 1.0;
			yaw_change = 1;
			flag = 1;
		}
	}
	yaw = yaw * 1.5;
     */
		
	//PID
    /*
	static double gainx[3] = {0.5, 0.001, 0.5};
	static double gainz[3] = {0.5, 0.001, 0.5};
	static double gainy[3] = {3.0, 0.01, 0.5};
     */
    
  
    /*
    static double gainx[3] = {0.7, 0., 7.6};
    static double gainy[3] = {0.7, 0., 7.6};
     */
    /*
    static double gainx[3] = {0.62, 0., 3.};
    static double gainy[3] = {0.62, 0., 3.};
    */
    
    /*
	double ingx = 0.0, ingz = 0.0;
	double prex = 0.0, prez = 0.0;
     */

	clock2=clock();
	elapse=clock2-clock1;
	clock1=clock2;
    printf("Elapsed: %f\n",elapse/1000.f);

	float dx = pid_control2_x(gmx, mx, gainx, elapse/1000.f);
    float dz = pid_control2_z(gmz, mz, gainz, elapse/1000.f);
    float dy = pid_control2_y(gmy, my, gainy, elapse/1000.f);

    
    //TODO: !!!! Make sure we don't get a 'jump' value when PID 'returns' from hyseteresis
    if (fabs(gmx-mx)<hysterx[0] && fabs(gmy-my)<hystery[0]) {
        x_hyster = 1;
        y_hyster = 1;
    } else if (fabs(gmx-mx)>hysterx[1] && x_hyster==true) {
        x_hyster = 0;
        y_hyster = 0;
    }
    
    if (fabs(gmz-mz)<hysterz[0]) {
        z_hyster = 1;
    } else if (fabs(gmz-mz)>hysterz[1] && z_hyster==true) {
        z_hyster = 0;
    }
    
    if (x_hyster==1) {
        dx = 0;
    }
    if (y_hyster==1) {
        dy = 0;
    }
    if (z_hyster==1) {
        dz = 0;
    }

	/*
	//pitch = pitch * 0.5;
	//roll = roll * 0.5;
	pitch = pitch * (1-absf(yaw * 0.5));
	roll = roll * (1-absf(yaw * 0.5));
		
	const double eps = 0.1;
	double dx = gmx - mx;
	double dz = gmz - mz;
	double dist = sqrt(dz*dz + dx*dx);

	//if (yaw_change) goto doit;
	if (dist < eps) goto doit;
	*/

    if (fabs(dx)>1) {
        printf("WARNING! DX CHOPPED! (was %f)\n",dx);
    }
	dx = chop(dx, -1.0, 1.0);

    if (fabs(dy)>1) {
        printf("WARNING! DY CHOPPED! (was %f)\n",dy);
    }
    dy = chop(dy, -1.0, 1.0);
    
	/*
	double tz = dz * cos(mya) + dx * sin(mya);
	double tx = -dz * sin(mya) + dx * cos(mya);

	double dist_p = chop(dist, 0.0, 1.0);

	pitch = pitch * (1-absf(yaw * 0.5));
	roll = roll * (1-absf(yaw * 0.5));
	*/

	//sang - test
	roll = dx;
	pitch = dy;


	/*
	double eps = 0.03;
	double dy = gmy - my;

	if(dy > eps){
		gaz = dy * 1.5;
	}else if(dy < -eps){
		gaz = dy * 1.5;
	}
	gaz = gaz * 1.5;
	*/

	dz = chop(dz, -1.0, 2.0);
	gaz = dz;
    

	*p = pitch;
	*r = roll;
	*y = yaw;
	*g = gaz;
}
