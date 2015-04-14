//
//  control.h
//  networkUdpReceiverExample
//
//  Created by Sang Leigh on 2/16/15.
//
//
#ifndef PID_H
#define PID_H


#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define chop(x,min,max) (x) > (max) ? (max) : (x) < (min) ? (min) : (x)
#define absf(x) ((x) > 0.0 ? (x) : -(x))

/* control */
extern double mx, my, mz, mp, mr, mya, lastSetMy;
extern double gmx, gmy, gmz, gmp, gmr, gmya;

extern int start_pid;
//extern double ar_err;
//extern float ar_pitch, ar_roll, ar_yaw, ar_gaz;
extern int ar_battery;

extern double min_x, min_z, min_y;
extern double max_x, max_z, max_y;

extern double diff[3][3];
extern double gain[3];
extern double integral[3];
extern clock_t clock1;
extern clock_t clock2;
extern double elapse;

extern double gainx[3];
extern double gainy[3];
extern double gainz[3];

extern double hysterx[3];
extern double hystery[3];
extern double hysterz[3];

extern int x_hyster;
extern int y_hyster;
extern int z_hyster;


/* functions */
void set_x_z_y_o(double x, double z, double y, double o);

void drone_control(float *p, float *r, float *y, float *g);

#endif /* MOCAP_H */
