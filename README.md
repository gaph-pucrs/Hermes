# Hermes

Wormhole packet-switching Network-on-Chip with XY routing.

## Testing

Inside [sim/](sim/) there is a script for simulating with modelsim:
```
vsim -c -do sim.do
```

The simulation parameters are present in [sim/tb.sv](sim/tb.sv).
Change the parameters `X_SIZE` and `X_SIZE` to simulate.

To generate simulation traffic, run the script present in [sim/inputs](sim/inputs/)
```
./traffic-generator.py
```

It is possible to customize the traffic generator parameters in [traffic-generator.py](sim/inputs/traffic-generator.py).
Please check the parameters `size`, `bandwidth`, `rate`, `amount`, `x_total`, and `y_total`.

## Acknowledgements

* Hermes
```
Moraes, F., Calazans, N., Mello, A., Möller, L., and Ost, L. (2004). HERMES: an infrastructure for low area overhead packet-switching networks on chip. Integration, 38(1):69-93.
```
