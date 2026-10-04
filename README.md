# I2C Slave Verification

This project contains an I2C slave RTL design and a reusable UVM verification
environment for testing its register-file interface. The testbench exercises
normal reads and writes, invalid slave addresses, read-only registers, unmapped
register locations, and reset behavior. It includes a UVM register model,
predictor, scoreboard, and functional coverage.

## Documentation

- [RTL specification](verification/RTL/I2C_Peripheral_RTL_Specification.md)
  describes the design, register map, and I2C read/write behavior.
- [UVM testbench documentation](verification/documnents/UVM_Testbench_Documentation.md)
  explains the verification environment, sequences, tests, checking, and
  coverage.
- [PDF specification](spec_doc/i2c_spec_doc.pdf) is an additional specification
  document.
- The Questa simulation scripts are in `verification/sim/`. The functional
  coverage report is `verification/sim/coverage/merged_coverage_report.txt`.

## Repository structure

```text
.
├── spec_doc/
│   └── i2c_spec_doc.pdf
├── verification/
│   ├── RTL/
│   │   ├── I2C_Peripheral_RTL_Specification.md
│   │   ├── i2c_peripheral_top.v
│   │   ├── i2c_slave_core.v
│   │   └── register_file.v
│   ├── documnents/
│   │   ├── UVM_Testbench_Documentation.md
│   │   └── design and verification diagrams
│   ├── sim/
│   │   ├── coverage/
│   │   │   └── coverage databases and report
│   │   └── Questa .do scripts
│   └── testbench/
│       └── UVM agents, sequences, tests, register model, and environment
├── .gitignore
├── LICENSE
└── README.md
```

Simulation-generated files are excluded from version control except for the
coverage directory and Questa `.do` scripts. Excel workbooks are also excluded.
