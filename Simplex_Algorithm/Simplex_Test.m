clear
clc

c = [4; 3];
A = [1 1; 2 1];
b = [40; 60];
eqSigns = {'<=', '<='};
simplex(c, A, b, eqSigns);

c = [60; 30; 20];
A = [8 6 1; 4 2 1.5; 2 1.5 0.5; 0 1 0];
b = [48; -20; 8; 5];
eqSigns = {'<=', '<=', '<=', '<='};
simplex(c, A, b, eqSigns);