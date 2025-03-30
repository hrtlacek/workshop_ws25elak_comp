import("stdfaust.lib");

var = hslider("test", 0, 0,1,0.001);

C1 = 0.47 * pow(10,-6);
C2 = 0.1 * pow(10,-6)*(0.1 + var*50);
R1 = 1.2 * pow(10,3);
// R2 = 6.8 * pow(10,3);

R2 = abs(os.osc(0.1)*2000) + 1000;

Rout = 100000;
Rin = 0.1;
Is = pow(10,-15);
Vt = 26 * pow(10,-3);

clipper(U) = wd.buildtree(tree)
with{

c1(i) = wd.capacitor(i,C1);
c2(i) = wd.capacitor(i,C2);

r1(i) = wd.resistor(i,R1);
r2(i) = wd.resistor(i,R2);

diodes(i) = wd.u_diodeAntiparallel(i, Is, Vt,1,1);
vin(i) = wd.resVoltage(i, Rin,U); // wd.u_voltage(i,U);

vout(i) = wd.resistor_Vout(i,Rout);

// tree = diodes : wd.parallel:(vout, (wd.parallel:(r2, wd.parallel:(c2, wd.series:(c1, wd.series:(r1,vin))))));
tree = diodes : wd.parallel:(vout, (wd.parallel:(r2, (wd.parallel:(c2, (wd.series:(c1, (wd.series:(r1,vin)))))))));
// tree = _;
// tree = diodes : wd.parallel:(vout,vin);

// tree = diodes : wd.parallel:(vout,(wd.series:(vin,r1)));

};

process = os.osc(100)*5:clipper;