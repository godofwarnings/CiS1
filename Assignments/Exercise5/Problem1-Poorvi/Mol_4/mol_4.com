%chk=mol_4.chk
# hf/3-21g geom=connectivity

mol_4

0 1
 C                  6.62774853    1.82617469   -0.57170030
 C                  8.12886353    1.82617469   -0.57170030
 C                  7.37827853    3.12614969   -0.57170030
 H                  8.66542453    1.51640769    0.34218770
 H                  7.37805553    3.74567769    0.34224370
 H                  7.37805553    3.74567769   -1.48564430
 C                  5.87932142    1.39397085   -1.84632052
 H                  5.78133889    0.32853547   -1.85844031
 H                  4.90756195    1.84167184   -1.85845992
 H                  6.42905261    1.71140790   -2.70767372
 C                  5.87932142    1.39397085    0.70291991
 H                  4.90755738    1.84166208    0.71505333
 H                  5.78134963    0.32853455    0.71504570
 H                  6.42904644    1.71141857    1.56427311
 C                  8.87725707    1.39411268   -1.84638832
 H                  8.62144266    0.38284528   -2.08471001
 H                  8.59816073    2.03332175   -2.65781730
 C                 10.39552182    1.49753673   -1.61021970
 H                 10.67289617    0.86694041   -0.79149401
 H                 10.65291619    2.51095632   -1.38299979
 C                 11.14411882    1.04998152   -2.87943082
 H                 10.87857710    0.04004028   -3.11268236
 H                 10.87481834    1.68719291   -3.69572667
 C                 12.66248835    1.13887887   -2.63807793
 H                 12.93078482    0.50690057   -1.81739502
 H                 12.92902249    2.15008572   -2.41153816
 C                 13.41110105    0.68197068   -3.90394283
 H                 13.14261211    1.31379358   -4.72468244
 H                 13.14475898   -0.32931883   -4.13033946
 C                 14.92947017    0.77121081   -3.66271391
 H                 15.19782919    0.14006379   -2.84141197
 H                 15.44961119    0.45291347   -4.54194091
 H                 15.19594046    1.78265970   -3.43718179

 1 2 1.0 3 1.0 7 1.0 11 1.0
 2 3 1.0 4 1.0 15 1.0
 3 5 1.0 6 1.0
 4
 5
 6
 7 8 1.0 9 1.0 10 1.0
 8
 9
 10
 11 12 1.0 13 1.0 14 1.0
 12
 13
 14
 15 16 1.0 17 1.0 18 1.0
 16
 17
 18 19 1.0 20 1.0 21 1.0
 19
 20
 21 22 1.0 23 1.0 24 1.0
 22
 23
 24 25 1.0 26 1.0 27 1.0
 25
 26
 27 28 1.0 29 1.0 30 1.0
 28
 29
 30 31 1.0 32 1.0 33 1.0
 31
 32
 33
